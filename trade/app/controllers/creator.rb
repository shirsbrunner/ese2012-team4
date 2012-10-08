def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/module/user')
require_relative('../models/module/item')

include Models

module Controllers
  class Creator < Sinatra::Base
    set :views, relative('../../app/views')
    helpers Sinatra::ContentFor

    post '/create' do
      unless session[:username].nil?
        user = session[:username]
        price = params[:price]

        unless Item.valid_price?(price)
          redirect "create/not_a_number"
        end
        #error handling for empty names or whitespaces (strip removes all kind of whitespaces, but not the first space)
        unless params[:name].strip.delete(' ')!=""
          redirect '/create/no_name'
        end
        User.get_user(user).create_item(params[:name], Integer(params[:price]), params[:description])
          # MW: maybe "User.by_name" might be somewhat more understandable
        redirect "/home/inactive"
      else
        redirect "/"
      end
    end

    get '/create/:error_msg' do
      case params[:error_msg]
        when "not_a_number"
          haml :home_new, :locals =>{:action => "create", :name => "", :price => "", :description =>"", :button => "Create", :page_name => "New Item", :error => "Your price is not a valid number!"}
        when "no_name"
          haml :home_new, :locals =>{:action => "create", :name => "", :price => "", :description =>"", :button => "Create", :page_name => "New Item", :error => "You have to choose a name for your item!"}
      end
    end

    post '/edit_item/:itemid' do
      #error handling for empty names or whitespaces (strip removes all kind of whitespaces, but not the first space)
      unless params[:name].strip.delete(' ')!=""
        redirect "/home/edit_item/#{params[:itemid]}/no_name"
      end
      item = Item.get_item(params[:itemid])
      price = params[:price]
      unless Item.valid_price?(String(price))
        redirect "/home/edit_item/#{params[:itemid]}/not_a_number"

      end
      item.delete # MW: should not be necessary => Refactor-Issue (the list @@items should be reorganized...)
      item.name = params[:name]
      item.price = params[:price].to_i
      item.description = params[:description]
      item.save # MW: should not be necessary, since the item is already in the system and only its properties have changed!
      redirect "/home/inactive"
    end

   
    get '/changestate/:id/setactive' do
      if not session[:username].nil?
        id = params[:id]
        Item.get_item(id).active = true
        redirect "/home/inactive"
      else
        redirect "/"
      end
    end

    get '/changestate/:id/setinactive' do
      if not session[:username].nil?
        id = params[:id]
        Item.get_item(id).active = false
        redirect "/home/active"
      else
        redirect "/"
      end
    end

    get '/buy/:id' do               # TODO: change to post!
      if not session[:username].nil?
        id = params[:id]
        item = Item.get_item(id)
        old_user = item.owner
        user = session[:username]
        new_user = User.get_user(user)
        if new_user.buy_new_item?(item)
          old_user.remove_item(item)
        else
          if back.include? '/not_enough_credits'
            redirect "#{back}"
          else
            redirect "#{back}/not_enough_credits"
          end
        end
        redirect "/home/inactive"
      else
        redirect "/"
      end
    end

  end
end
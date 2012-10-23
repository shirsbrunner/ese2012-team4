def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require 'rack-flash'
require_relative('../models/module/user')
require_relative('../models/module/item')
require_relative('helper')

include Models

module Controllers
  class ItemControl < Sinatra::Base
    set :views, relative('../../app/views')
    helpers Sinatra::ContentFor
    use Rack::Flash

    before do
      @session_user = User.get_user(session[:id])
    end

    get '/home/items' do
      redirect '/index' unless session[:id]
      haml :user_items, :locals => {:page_name => "My items"}
    end

    get '/home/new' do
      redirect '/index' unless session[:id]
      @item = Item.created("", "", "", "", "");
      haml :item_edit, :locals =>{:action => "create", :button => "Create", :page_name => "New Item"}
    end

    get '/home/edit_item/:itemid' do
      redirect '/index' unless session[:id]
      if Item.get_item(params[:itemid]).is_owner?(@session_user.id)

        @item = Item.get_item(params[:itemid])
        #RB: Not needed, if we assume that the system is in a valid state before
        #unless Item.valid_integer?(item_price)
        #  redirect "/home/edit_item/#{params[:itemid]}/not_a_number"
        #end

        haml :item_edit, :locals => {:action => "change/#{params[:itemid]}", :button => "Save changes", :page_name => "Edit Item"}
      else
        redirect "/"
      end
    end

    get '/items/:page' do
      redirect '/index' unless session[:id]

      items_per_page = 20
      page = params[:page].to_i
      items = Item.get_all(@session_user.name)
      (items.size%20)==0? page_count = (items.size/20).to_i : page_count = (items.size/20).to_i+1
      redirect 'items/1' unless 0<params[:page].to_i and params[:page].to_i<page_count+1
      @all_items = []
      for i in ((page-1)*items_per_page)..(page*items_per_page)-1
        @all_items<<items[i] unless items[i].nil?
      end
      haml :all_items, :locals => {:page_name => "Items", :page => page, :page_count => page_count}
    end

    get '/items' do
      redirect '/index' unless session[:id]
      redirect '/items/1'
    end

    get '/item/:itemid' do
      redirect '/index' unless session[:id]
      id = params[:itemid]
      @item = Item.get_item(id)
      haml :item_page, :locals => {:page_name => "Item #{@item.name}"}
    end

    post '/create' do
      redirect '/index' unless session[:id]
      name = params[:name]
      price = params[:price]
      owner = @session_user
      quantity = params[:quantity]
      description = params[:quantity]

      filename = save_image(params[:image_file])

      item = Item.created(name, price, owner, quantity, description, filename)
      unless item.is_valid
        flash[:error] = item.errors
        redirect "/home/new"
      end
      
      @session_user.create_item(params[:name], Integer(price), Integer(quantity), params[:description], filename)
      flash[:notice] = "Item has been created"
      redirect "/home/items"
    end

    get "/item/:id/image" do
      redirect '/index' unless session[:id]
      path = Item.get_item(params[:id]).image
      if path == ""
        send_file(File.join(FileUtils::pwd, "public/images/item_pix/placeholder_item.jpg"))
      else
        send_file(path)
      end
    end

    post '/change/:itemid' do
      redirect '/index' unless session[:id]

      filename = save_image(params[:image_file])
      test_item = Item.created(params[:name], params[:price], @session_user, params[:quantity], params[:description], filename)
      unless test_item.is_valid
        flash[:error] = test_item.errors
        redirect "/home/edit_item/#{params[:itemid]}"
      else
        item = Item.get_item(params[:itemid])
        item.edit(params[:name],Integer(params[:price]),Integer(params[:quantity]),params[:description], filename)
        flash[:notice] = "Item has been changed"
        redirect "/home/items"
      end
    end

    post '/changestate/:id/setactive' do
      redirect '/index' unless session[:id]
      id = params[:id]
      owner = Item.get_item(id).owner
      owner.activate_item(id)
      flash[:notice] = "Item has been activated"
      redirect "/home/items"
    end

    post '/changestate/:id/setinactive' do
      redirect '/index' unless session[:id]
      id = params[:id]
      owner = Item.get_item(id).owner
      owner.deactivate_item(id)
      flash[:notice] = "Item has been deactivated"
      redirect "/home/items"
    end

    post '/buy/:id/:timestamp' do
      redirect '/index' unless session[:id]
      id = params[:id]
      quantity = Integer(params[:quantity])
      item = Item.get_item(id)
      old_user = item.owner
      user = session[:id]
      new_user = User.get_user(user)
      if (Integer(params[:timestamp])-item.timestamp)!=0
        flash[:error] = "Item has been edited while you were buying it"
        redirect "#{back}"
      end
      unless new_user.buy_new_item(item, quantity)
        flash[:error] = "You don't have enough credits"
        redirect "#{back}"
      end
      flash[:notice] = "You have bought the item"
      redirect "/home/items"
    end

    get "/comments/:item_id" do
      redirect "/index" unless session[:id]
      item_name = Item.get_item(params[:item_id]).name
      @item = Item.get_item(params[:item_id])
      haml :comments, :locals => {:page_name => "Comments on #{@item.name}"}
    end

    get '/reply/:comment_id' do
      redirect "/index" unless session[:id]
      @comment = Comment.by_id(params[:comment_id])
      haml :reply, :locals => {:page_name => "Reply on #{@comment.author.name}'s comment"}
    end

    get '/comment/:item_id' do
      redirect "/index" unless session[:id]
      @item = Item.get_item(params[:item_id])
      haml :create_comment, :locals => {:page_name => "Write a comment for #{@item.name}"}
    end

    post '/answer/:comment_id' do
      redirect '/index' unless session[:id]
      comment = Comment.by_id(params[:comment_id])
      comment.answer(@session_user, params[:reply])
      redirect "/comments/#{comment.correspondent_item.id}"
    end

    post '/create_comment/:item_id' do
      redirect '/index' unless session[:id]
      item = Item.get_item(params[:item_id])
      item.comment(@session_user, params[:com])
      redirect "/comments/#{params[:item_id]}"
    end
  end
end
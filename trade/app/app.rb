def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'rubygems'
require 'require_relative'
require 'sinatra'
require 'haml'
require_relative('controllers/not_authenticated')
require_relative('controllers/item_control')
require_relative('controllers/user_control')
require_relative('controllers/comment_control')

require_relative('../../trade/app/models/module/item')
require_relative('../../trade/app/models/module/user')

include Models
include Controllers

class App < Sinatra::Base

  use Not_authenticated
  use ItemControl
  use CommentControl
  use UserControl

  enable :sessions
  enable :method_override
  set :views, relative('app/views')
  set :public_folder, relative('public')

  configure :development do
    userA = User.created( "userA", "passwordA", "e_mail_A@preset.com" )
    userA.save
    aa = userA.create_item("UserA_ItemA", 10, 1)
    ab = userA.create_item("UserA_ItemB", 50, 1)
    ab.active = true
    ac = userA.create_item("UserA_ItemC", 120, 1)
    ac.active = true
    co = ac.comment(userA, "Great Item! Please buy it!")


    userB = User.created( "userB", "passwordB", "e_mail_B@preset.com" )
    userB.save
    ba = userB.create_item("UserB_ItemA", 10, 2)
    ba.active = true
    bb = userB.create_item("UserB_ItemB", 2, 100)
    bb.active = true
    bc = userB.create_item("UserB_ItemC", 120, 1)
    for i in 0..200
      userB.create_item("User_B#{i}",10,1).active=true
    end
    co.answer(userB, "It doesn't seems that great. Do you have a picture of it?")

    userC = User.created( "userC", "passwordC", "e_mail_C@preset.com" )
    userC.save
    ca = userC.create_item("UserC_ItemA", 10, 1)
    ca.active = true
    cb = userC.create_item("UserC_ItemB", 50, 1)
    cc = userC.create_item("UserC_ItemC", 120, 1)
    cc.active = true
    co.answer(userC, "You're right userB!")

    ese = User.created( "ese", "ese", "ese@preset.com" )
    ese.save

    end

  end

App.run!
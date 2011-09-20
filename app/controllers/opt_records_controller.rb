class OptRecordsController < ApplicationController
  include DiariesChildrenHelper

  before_filter(:authenticate, :only => [:create])
  before_filter(:diary_exist)
  before_filter(:author_of_diary, :only => [:create])

  def create
  end
end

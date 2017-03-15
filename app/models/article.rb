require 'elasticsearch/model'

class Article < ActiveRecord::Base
  has_many :comments, dependent: :destroy

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  validates :title, presence: true, length: { minimum: 5 }
  validates :text, presence: true, length: { minimum: 10 }
  after_save :notify_subscribers

  def notify_subscribers
    Backburner::Worker.enqueue(NotifyJob, [self])
  end
end

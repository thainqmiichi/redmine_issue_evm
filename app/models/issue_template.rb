class IssueTemplate < ActiveRecord::Base
  belongs_to :tracker

  validates :name, presence: true
  validates :tracker_id, presence: true
  validates :subject, presence: true
end

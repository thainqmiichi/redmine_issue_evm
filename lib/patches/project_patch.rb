module RedmineIssueEvm
  module ProjectPatch
    extend ActiveSupport::Concern

    included do
      has_one  :evmsetting,  class_name: 'Evmsetting',  foreign_key: 'project_id'
      has_many :evmbaselines, class_name: 'Evmbaseline', foreign_key: 'project_id'
    end
  end
end

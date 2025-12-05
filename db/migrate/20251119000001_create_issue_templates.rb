class CreateIssueTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :issue_templates do |t|
      t.string  :name
      t.integer :tracker_id
      t.string  :subject
      t.text    :description
    end

    add_index :issue_templates, :tracker_id
  end
end

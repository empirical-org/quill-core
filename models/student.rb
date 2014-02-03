module Student
  extend ActiveSupport::Concern

  included do
    has_one :classroom, foreign_key: 'code', primary_key: 'classcode'
    has_one :teacher, through: :classroom

    has_many :assigned_activities, through: :classroom, source: :activities
    has_many :started_activities, through: :activity_sessions, source: :activity

    has_many :assigned_activities, through: :classroom, source: :activities
    has_many :started_activities, through: :activity_sessions, source: :activity

    def unfinished_activities classroom
      classroom.activities - finished_activities(classroom)
    end

    def finished_activities classroom
      classroom_activity_score_join(classroom).where('activity_sessions.completion_date is not null')
    end

    def classroom_activity_score_join classroom
      started_activities.where(classroom_activities: { classroom_id: classroom.id })
    end
    protected :classroom_activity_score_join

    has_many :activity_sessions, dependent: :destroy do
      def for_activity activity
        includes(:classroom_activity).where(classroom_activities: { activity_id: activity.id }).last
      end
    end
  end
end

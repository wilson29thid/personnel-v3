class Enlistment < ApplicationRecord
  include HasForumTopic
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :liaison, class_name: "User", foreign_key: "liaison_member_id",
                       optional: true
  belongs_to :recruiter_user, class_name: "User", foreign_key: "recruiter_member_id",
                              optional: true # There's already a column called recruiter
  belongs_to :country
  belongs_to :unit, optional: true

  enum status: {pending: "Pending", accepted: "Accepted", denied: "Denied",
                withdrawn: "Withdrawn", awol: "AWOL"}
  enum timezone: {est: "EST", gmt: "GMT", pst: "PST", any_timezone: "Any", no_timezone: "None"}
  enum game: {dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}

  validates :user, presence: true
  validates :date, timeliness: {date: true}
  validates :first_name, presence: true, length: {in: 1..30}
  validates :middle_name, length: {maximum: 1}
  validates :last_name, presence: true, length: {in: 2..40}
  validates :age, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 13, less_than_or_equal_to: 99}
  validates :timezone, presence: true
  validates :game, presence: true
  validates :ingame_name, length: {maximum: 60}
  validates :steam_id, numericality: {only_integer: true} # validate length?
  validates :experience, presence: true
  validates :recruiter, length: {maximum: 128}

  serialize :previous_units, JSON
  validates_associated :previous_units

  # change table to allow nulls in unused fields
  # check last_name against restricted names
  # serialize units as array of objects, ideally typed/validated

  before_create :set_date
  before_validation :shorten_middle_name

  attr_reader :previous_units

  def previous_units=(hashes)
    @previous_units = hashes.empty? ? [] : hashes.map { |hash| PreviousUnit.new(hash) }
    super(@previous_units)
  end

  private

  def set_date
    self.date = Date.current
  end

  def shorten_middle_name
    self.middle_name = middle_name ? middle_name[0] : ""
  end
end
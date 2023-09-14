# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
$season_id = Season.find(1).id#Season.create!(name: 'Winter 2022/2023', start: Date.new(2022, 11, 11), end: Date.new(2023, 4, 23)).id

$base_role_ids = {
  admin: Role.find_by(name: :admin).id,
  onhill: Role.find_by(name: :onhill).id,
  #aidroom: Role.find_by(name: :aidroom).id,
  #host: Role.find_by(name: :host).id
}

$role_resourced = {
  admin: false,
  onhill: true,
  leader: true,
  #aidroom: true,
  #host: true,
  director: true,
  rigger: true,
  senior: false,
  avy1: false,
  avy2: false,
  mtr: false
}

def find_or_create_responsibility(name:, version:, role_id:)
  pr = PatrolResponsibility.find_by(name: name)
  if pr.nil?
    pr_id = PatrolResponsibility.create!(name: name, version: version, role_id: role_id).id
  else
    pr_id = pr.id
  end
  pr_id
end

$responsibility_ids = {
  lead: find_or_create_responsibility(name: 'Team leader', version: 15, role_id: $base_role_ids[:onhill]),
  p1: find_or_create_responsibility(name: 'P1', version: 15, role_id: $base_role_ids[:onhill]),
  p2: find_or_create_responsibility(name: 'P2', version: 15, role_id: $base_role_ids[:onhill]),
  p3: find_or_create_responsibility(name: 'P3', version: 15, role_id: $base_role_ids[:onhill]),
  p4: find_or_create_responsibility(name: 'P4', version: 15, role_id: $base_role_ids[:onhill]),
  p5: find_or_create_responsibility(name: 'P5', version: 15, role_id: $base_role_ids[:onhill]),
  s1: find_or_create_responsibility(name: 'S1', version: 15, role_id: $base_role_ids[:onhill]),
  s2: find_or_create_responsibility(name: 'S2', version: 15, role_id: $base_role_ids[:onhill]),
  s3: find_or_create_responsibility(name: 'S3', version: 15, role_id: $base_role_ids[:onhill]),
  s4: find_or_create_responsibility(name: 'S4', version: 15, role_id: $base_role_ids[:onhill]),
  s5: find_or_create_responsibility(name: 'S5', version: 15, role_id: $base_role_ids[:onhill]),
  mw1: find_or_create_responsibility(name: 'Midweek 1', version: 15, role_id: $base_role_ids[:onhill]),
  mw2: find_or_create_responsibility(name: 'Midweek 2', version: 15, role_id: $base_role_ids[:onhill]),
  mw3: find_or_create_responsibility(name: 'Midweek 3', version: 15, role_id: $base_role_ids[:onhill]),
  mw4: find_or_create_responsibility(name: 'Midweek 4', version: 15, role_id: $base_role_ids[:onhill]),
  h1: find_or_create_responsibility(name: 'Host 1', version: 1, role_id: $base_role_ids[:host]),
  h2: find_or_create_responsibility(name: 'Host 2', version: 1, role_id: $base_role_ids[:host]),
  h3: find_or_create_responsibility(name: 'Host 3', version: 1, role_id: $base_role_ids[:host]),
  h4: find_or_create_responsibility(name: 'Host 4', version: 1, role_id: $base_role_ids[:host]),
  base: find_or_create_responsibility(name: 'Base', version: 15, role_id: $base_role_ids[:onhill])
}

def create_duty_days(duty_day_hashes)
  duty_day_hashes.sort! { |a, b| a[:date] <=> b[:date] }
  duty_day_hashes.each { |dd| DutyDay.create!(season_id: $season_id, **dd) }
end

module SecureRandom::RNG
  def self.rand(max)
    SecureRandom.random_number(max)
  end
end

def random_pass
  [*('a'..'z'),*('0'..'9'),*('A'..'Z')].shuffle(random: SecureRandom::RNG)[0,14].join
  #'test12345'
end

def email_new_user(user)
  user.generate_token(:password_reset_token)
  user.password_reset_sent_at = Time.now
  user.save!(validate: false)
  UserMailer.new_user(user).deliver_now
end

def create_patrols(user, team_duty_day_ids)
  unless user[0].nil?
    puts user[0].name
  end
  team_duty_day_ids.zip(user[1]).each do |user_duty_resp|
    if (user[0].nil? || user[0].reserve)
      uid = nil
    else
      uid = user[0].id
    end
    Patrol.create!(user_id: uid, duty_day_id: user_duty_resp[0], patrol_responsibility_id: $responsibility_ids[user_duty_resp[1]])
  end
end

def seed_members(role, team_id, team_members, team_duty_day_ids)
  team_members.each do |member|
    created = false
    unless member[0].nil?
      user = User.find_by(email: member[0][:email])
      if user.nil? 
        #try first and last name, maybe they changed their email
        user = User.find_by(first_name: member[0][:first_name], last_name: member[0][:last_name])
      end
      if user.nil?
        user = User.create!(**(member[0]))
        r = RosterSpot.create!(user_id: user.id, team_id: team_id, season_id: $season_id)
        created = true
      else
        r = user.season_roster_spot($season_id)
        if r.nil?
          r = RosterSpot.create!(user_id: user.id, team_id: team_id, season_id: $season_id)
        end
      end
      add_extra_roles(user, r, member[2])
      member[0] = user
      member[0].add_role(role, r) unless member[0].has_role?(role, r)
    end
    create_patrols(member, team_duty_day_ids)
    #if created
    #  email_new_user(member[0])
    #end
  end
end

def seed_leader(role, team_id, leader, team_duty_day_ids)
  created = false
  user = User.find_by(email: leader[0][:email])
  if user.nil? 
    #try first and last name, maybe they changed their email
    user = User.find_by(first_name: leader[0][:first_name], last_name: leader[0][:last_name])
  end
  if user.nil?
    user = User.create!(**(leader[0]))
    r = RosterSpot.create!(user_id: user.id, team_id: team_id, season_id: $season_id)
    created = true
  else
    r = user.season_roster_spot($season_id)
    if r.nil?
      r = RosterSpot.create!(user_id: user.id, team_id: team_id, season_id: $season_id)
    end
  end
  add_extra_roles(user, r, leader[2])
  leader[0] = user
  leader[0].add_role(role, r)
  leader[0].add_role(:leader, r)
  create_patrols(leader, team_duty_day_ids)
  #if created
  #  email_new_user(leader[0])
  #end
end

def seed_weekend(role, team_id, team_members, team_duty_day_ids)
  seed_leader(role, team_id, team_members[0], team_duty_day_ids)
  seed_members(role, team_id, team_members[1..-1], team_duty_day_ids)
end

def seed_midweek(role, team_id, team_members, team_duty_day_ids)
  chunk = 0 #TODO ONLY FOR TESTING, should be 0
  seed_leader(role, team_id, team_members[0], team_duty_day_ids)
  team_members[1..-1].each_slice(4) do |midweek_team|
    puts "Seeding a midweek team"
    midweek_team_duty_day_ids = chunk.step(team_duty_day_ids.size-1, 2).map { |i| team_duty_day_ids[i] }
    seed_members(role, team_id, midweek_team, midweek_team_duty_day_ids)
    chunk += 1
  end
end

def add_extra_roles(user, roster_spot, roles) 
  roles.each do |role|
    if $role_resourced[role]
      user.add_role(role, roster_spot) unless user.has_role?(role, roster_spot)
    else
      user.add_role(role) unless user.has_role?(role)
    end
  end
end

teams = {
  trainer: Team.find_by(name: 'Trainer Team').id,#Team.create!(name: 'Trainer Team').id,
  midweek: Team.find_by(name: 'Midweek Team').id,#Team.create!(name: 'Midweek Team').id,
  a: Team.find_by(name: 'A Team').id,#Team.create!(name: 'A Team').id,
  b: Team.find_by(name: 'B Team').id,#Team.create!(name: 'B Team').id,
  c: Team.find_by(name: 'C Team').id,#Team.create!(name: 'C Team').id,
  d: Team.find_by(name: 'D Team').id,#Team.create!(name: 'D Team').id
  #host: Team.find_by(name: 'Host Team').id,
}

duty_days = [
  #midweek
  {team_id: teams[:midweek], date: Date.new(2022, 11, 11)},
  {team_id: teams[:midweek], date: Date.new(2022, 11, 18)},
  {team_id: teams[:midweek], date: Date.new(2022, 11, 25)},
  {team_id: teams[:midweek], date: Date.new(2022, 12, 2)},
  {team_id: teams[:midweek], date: Date.new(2022, 12, 9)},
  {team_id: teams[:midweek], date: Date.new(2022, 12, 16)},
  {team_id: teams[:midweek], date: Date.new(2022, 12, 23)},
  {team_id: teams[:midweek], date: Date.new(2022, 12, 30)},
  {team_id: teams[:midweek], date: Date.new(2023, 1, 6)},
  {team_id: teams[:midweek], date: Date.new(2023, 1, 13)},
  {team_id: teams[:midweek], date: Date.new(2023, 1, 20)},
  {team_id: teams[:midweek], date: Date.new(2023, 1, 27)},
  {team_id: teams[:midweek], date: Date.new(2023, 2, 3)},
  {team_id: teams[:midweek], date: Date.new(2023, 2, 10)},
  {team_id: teams[:midweek], date: Date.new(2023, 2, 17)},
  {team_id: teams[:midweek], date: Date.new(2023, 2, 24)},
  {team_id: teams[:midweek], date: Date.new(2023, 3, 3)},
  {team_id: teams[:midweek], date: Date.new(2023, 3, 10)},
  {team_id: teams[:midweek], date: Date.new(2023, 3, 17)},
  {team_id: teams[:midweek], date: Date.new(2023, 3, 24)},
  {team_id: teams[:midweek], date: Date.new(2023, 3, 31)},
  {team_id: teams[:midweek], date: Date.new(2023, 4, 7)},
  {team_id: teams[:midweek], date: Date.new(2023, 4, 14)},
  {team_id: teams[:midweek], date: Date.new(2023, 4, 21)},
  #a team
  {team_id: teams[:a], date: Date.new(2022, 11, 19)},
  {team_id: teams[:a], date: Date.new(2022, 12, 3)},
  {team_id: teams[:a], date: Date.new(2022, 12, 17)},
  {team_id: teams[:a], date: Date.new(2022, 12, 31)},
  {team_id: teams[:a], date: Date.new(2023, 1, 14)},
  {team_id: teams[:a], date: Date.new(2023, 1, 28)},
  {team_id: teams[:a], date: Date.new(2023, 2, 11)},
  {team_id: teams[:a], date: Date.new(2023, 2, 25)},
  {team_id: teams[:a], date: Date.new(2023, 3, 11)},
  {team_id: teams[:a], date: Date.new(2023, 3, 25)},
  {team_id: teams[:a], date: Date.new(2023, 4, 8)},
  {team_id: teams[:a], date: Date.new(2023, 4, 22)},
  #b team
  {team_id: teams[:b], date: Date.new(2022, 11, 20)},
  {team_id: teams[:b], date: Date.new(2022, 12, 4)},
  {team_id: teams[:b], date: Date.new(2022, 12, 18)},
  {team_id: teams[:b], date: Date.new(2023, 1, 1)},
  {team_id: teams[:b], date: Date.new(2023, 1, 15)},
  {team_id: teams[:b], date: Date.new(2023, 1, 29)},
  {team_id: teams[:b], date: Date.new(2023, 2, 12)},
  {team_id: teams[:b], date: Date.new(2023, 2, 26)},
  {team_id: teams[:b], date: Date.new(2023, 3, 12)},
  {team_id: teams[:b], date: Date.new(2023, 3, 26)},
  {team_id: teams[:b], date: Date.new(2023, 4, 9)},
  {team_id: teams[:b], date: Date.new(2023, 4, 23)},
#   #c team
  {team_id: teams[:c], date: Date.new(2022, 11, 12)},
  {team_id: teams[:c], date: Date.new(2022, 11, 26)},
  {team_id: teams[:c], date: Date.new(2022, 12, 10)},
  {team_id: teams[:c], date: Date.new(2022, 12, 24)},
  {team_id: teams[:c], date: Date.new(2023, 1, 7)},
  {team_id: teams[:c], date: Date.new(2023, 1, 21)},
  {team_id: teams[:c], date: Date.new(2023, 2, 4)},
  {team_id: teams[:c], date: Date.new(2023, 2, 18)},
  {team_id: teams[:c], date: Date.new(2023, 3, 4)},
  {team_id: teams[:c], date: Date.new(2023, 3, 18)},
  {team_id: teams[:c], date: Date.new(2023, 4, 1)},
  {team_id: teams[:c], date: Date.new(2023, 4, 15)},
  #d team
  {team_id: teams[:d], date: Date.new(2022, 11, 13)},
  {team_id: teams[:d], date: Date.new(2022, 11, 27)},
  {team_id: teams[:d], date: Date.new(2022, 12, 11)},
  {team_id: teams[:d], date: Date.new(2022, 12, 25)},
  {team_id: teams[:d], date: Date.new(2023, 1, 8)},
  {team_id: teams[:d], date: Date.new(2023, 1, 22)},
  {team_id: teams[:d], date: Date.new(2023, 2, 5)},
  {team_id: teams[:d], date: Date.new(2023, 2, 19)},
  {team_id: teams[:d], date: Date.new(2023, 3, 5)},
  {team_id: teams[:d], date: Date.new(2023, 3, 19)},
  {team_id: teams[:d], date: Date.new(2023, 4, 2)},
  {team_id: teams[:d], date: Date.new(2023, 4, 16)},
]
create_duty_days(duty_days)

midweek_patrols_table = [
  [:mw1, :mw2, :mw3, :mw4, :mw1, :mw2, :mw3, :mw4, :mw1, :mw2, :mw3, :mw4],
  [:mw2, :mw3, :mw4, :mw1, :mw2, :mw3, :mw4, :mw1, :mw2, :mw3, :mw4, :mw1],
  [:mw3, :mw4, :mw1, :mw2, :mw3, :mw4, :mw1, :mw2, :mw3, :mw4, :mw1, :mw2],
  [:mw4, :mw1, :mw2, :mw3, :mw4, :mw1, :mw2, :mw3, :mw4, :mw1, :mw2, :mw3]
]

# common_onhill_patrols_table_9 = [
#   Array.new(13, :lead),
#   [:s1, :p2, :s3, :p4, :s1, :p5, :s4, :p1, :p3, :s3, :p4, :s2, :p3],
#   [:p1, :s2, :p3, :s1, :p2, :s4, :p4, :p5, :s3, :p3, :s1, :p2, :s4],
#   [:s2, :p3, :s4, :p5, :s3, :p1, :s1, :p2, :p4, :s4, :p5, :s3, :p2],
#   [:p5, :s3, :p2, :s4, :p1, :p4, :p3, :s1, :s2, :p2, :s4, :p1, :p4],
#   [:s3, :p4, :s1, :p1, :s4, :p2, :s2, :p3, :p5, :s1, :p1, :p5, :s2],
#   [:p3, :s4, :p5, :s2, :p4, :s1, :p2, :s3, :p1, :p5, :s2, :p4, :s1],
#   [:s4, :p5, :s2, :p2, :p3, :s3, :p1, :p4, :s1, :s2, :p2, :p3, :s3],
#   [:p4, :s1, :p1, :p3, :s2, :p3, :s3, :s4, :p2, :p1, :s3, :s4, :p5],
#   [:p2, :p1, :p4, :s3, :p5, :s2, :p5, :s2, :s4, :p4, :p3, :s1, :p1],
# ]

common_onhill_patrols_table_10 = [
  Array.new(12, :lead),
  [:p2, :s3, :p4, :s1, :p5, :s4, :p1, :p3, :s3, :s5, :s2, :s5],
  [:s5, :s1, :s2, :p2, :s4, :p4, :p5, :s3, :p3, :p1, :s5, :s1],
  [:s2, :s5, :p5, :s3, :p1, :s1, :p2, :p4, :s4, :s1, :p2, :p3],
  [:p3, :s4, :s5, :p1, :p4, :p3, :s1, :s2, :p2, :p5, :s3, :p1],
  [:p4, :p2, :s4, :s5, :p3, :s2, :s3, :p5, :s1, :s4, :p1, :p4],
  [:s3, :p3, :p1, :s4, :s5, :p2, :p3, :s1, :p5, :p4, :p5, :s2],
  [:s4, :p5, :p2, :p4, :s1, :s5, :p4, :p1, :s2, :s2, :p3, :s3],
  [:p5, :s2, :s1, :p3, :s3, :p1, :s5, :p2, :p1, :p2, :p4, :s4],
  [:s1, :p1, :p3, :s2, :p2, :s3, :s4, :s5, :p4, :s3, :s4, :p5],
  [:p1, :p4, :s3, :p5, :s2, :p5, :s2, :s4, :s5, :p3, :s1, :p2]
]

# host_patrols_table = [
#   [:h1, :h2, :h3, :h1, :h2, :h3, :h1, :h2, :h3, :h1, :h2, :h3],
#   [:h2, :h3, :h1, :h2, :h3, :h1, :h2, :h3, :h1, :h2, :h3, :h1],
#   [:h3, :h1, :h2, :h3, :h1, :h2, :h3, :h1, :h2, :h3, :h1, :h2],
#   [:h4, :h4, :h4, :h4, :h4, :h4, :h4, :h4, :h4, :h4, :h4, :h4]
# ]
# trainer team
#[{first_name: 'Dean', last_name: 'Collins', email: 'deanman63@gmail.com', phone: '(360)630-7106', password: random_pass()}, [], []],
trainer_members = [
  [{first_name: 'Krister', last_name: 'Fast', email: 'kkfast@yahoo.com', phone: '(360)220-2196', password: random_pass()}, [], [:director, :admin, :senior]],
  [{first_name: 'Dave', last_name: 'May', email: 'dave_may@q.com', phone: '(360)738-1103', password: random_pass()}, [], [:senior]],
  [{first_name: 'Jeff', last_name: 'Boyd', email: 'jsb57@comcast.net', phone: '(360)201-9602', password: random_pass()}, [], [:senior, :avy2]],
  [{first_name: 'Max', last_name: 'Duncan', email: 'duncanmfd@gmail.com', phone: '(360)599-1730', password: random_pass()}, [], [:mtr, :avy2]], #TODO avy?
  [{first_name: 'Kelly', last_name: 'Keilwitz', email: 'kelly@whidbeysunwind.com', phone: '(360)678-6233', password: random_pass()}, [], [:mtr, :avy2]], #TODO avy?
  [{first_name: 'Dick', last_name: 'Tucker', email: 'rtu2271093@aol.com', phone: '(360)734-8815', password: random_pass()}, [], []],
  [{first_name: 'Britta', last_name: 'Fast', email: 'britta.fast@outlook.com', phone: '(360)739-0236', password: random_pass()}, [], []],
  [{first_name: 'Jason', last_name: 'Kammerer', email: 'kammererjason@hotmail.com', phone: '(360)820-1233', password: random_pass()}, [], []],
  [{first_name: 'Mary', last_name: 'Davis', email: 'maryennesdavis@gmail.com', phone: '(360)224-7516', password: random_pass()}, [], [:mtr]],
  #reserve
  [{first_name: 'Jeff', last_name: 'Davis', email: 'Jeff.Davis@wwu.edu', phone: '(360)920-8041', password: random_pass()}, [], [:mtr]], 
  [{first_name: 'Bob', last_name: 'Hollingsworth', email: 'bobjhollingsworth@gmail.com', phone: '(360)733-7126', password: random_pass()}, [], [:mtr]],
  [{first_name: 'Erica', last_name: 'Littlewood', email: 'ericabellingham@gmail.com', phone: '(360)647-9382', password: random_pass()}, [], [:mtr]],
]
seed_members(:onhill, teams[:trainer], trainer_members, [])

# midweek team
# REMEMBER TO SWAP TEAMS IN ARRAY SO THEY LINE UP WITH THE RIGHT DUTY DAYS!!!!!!!!
midweek_duty_day_ids = DutyDay.where(season_id: $season_id, team_id: teams[:midweek]).order(date: :asc).pluck(:id)
midweek_members = [
  [{first_name: 'Bruce', last_name: 'Rustad', email: 'brucerustad@comcast.net', phone: '(360)293-3329', password: random_pass()}, Array.new(midweek_duty_day_ids.size, :lead), [:senior]],
  [{first_name: 'Ken', last_name: 'Henderson', email: 'khenders@kirklandwa.gov', phone: '(360)387-7199', password: random_pass()}, midweek_patrols_table[0], [:mtr, :avy2, :senior]],
  [{first_name: 'Dave', last_name: 'Richards', email: 'clickpop@mac.com', phone: '(360)961-9759', password: random_pass()}, midweek_patrols_table[1], []],
  [{first_name: 'Darrel', last_name: 'Vaught', email: 'devaughts@comcast.net', phone: '(360)738-8967', password: random_pass()}, midweek_patrols_table[2], []],
  [{first_name: 'Daniel', last_name: 'Sandler', email: 'danielsandler25@gmail.com', phone: '(206)660-3750', password: random_pass()}, midweek_patrols_table[3], []],
  [{first_name: 'Tim', last_name: 'Andress', email: 'tandress@hotmail.com', phone: '(360)927-8562', password: random_pass()}, midweek_patrols_table[0], []],
  [{first_name: 'Brian', last_name: 'Gilbert', email: 'gilbebl@hotmail.com', phone: '(360)420-6343', password: random_pass()}, midweek_patrols_table[1], []],
  [{first_name: 'John', last_name: 'Wilkins', email: 'johnlwilkins@gmail.com', phone: '(360)223-0179', password: random_pass()}, midweek_patrols_table[2], []],
  [{first_name: 'Adam', last_name: 'Morvee', email: 'adammorvee@gmail.com', phone: '(360)927-1723', password: random_pass()}, midweek_patrols_table[3], []]
]
seed_midweek(:onhill, teams[:midweek], midweek_members, midweek_duty_day_ids)

# A team
#[{first_name: 'Jon', last_name: 'Buettner', email: 'skidaddy81@hotmail.com', phone: '(360)325-2997', password: random_pass()}, common_onhill_patrols_table[2], []],
a_members = [
 [{first_name: 'Gerald', last_name: 'Craft', email: 'craftgerald@yahoo.com', phone: '(360)920-7708', password: random_pass()}, common_onhill_patrols_table_10[0], [:mtr]],
 [{first_name: 'Damian', last_name: 'Provalenko', email: 'damian@windermere.com', phone: '(360)303-5072', password: random_pass()}, common_onhill_patrols_table_10[1], []],
 [{first_name: 'Walter', last_name: 'Channel', email: 'walterchannel@gmail.com', phone: '(425)615-4618', password: random_pass()}, common_onhill_patrols_table_10[2], []],
 [{first_name: 'Kyle', last_name: 'Breakey', email: 'kyle.breakey@yahoo.com', phone: '(509)969-9612', password: random_pass()}, common_onhill_patrols_table_10[3], [:mtr, :avy2, :senior, :rigger]],
 [{first_name: 'Dan', last_name: 'Dickinson', email: 'dandebdickinson@gmail.com', phone: '(360)920-3380', password: random_pass()}, common_onhill_patrols_table_10[4], [:mtr]],
 [{first_name: 'Giancarlo', last_name: 'Bussani', email: 'liv2ride621@gmail.com', phone: '(604)772-0901', password: random_pass()}, common_onhill_patrols_table_10[5], []],
 [{first_name: 'Brian', last_name: 'MacSwan', email: 'bmacsurf@yahoo.com', phone: '(360)927-8534', password: random_pass()}, common_onhill_patrols_table_10[6], [:mtr]],
 [{first_name: 'Andy', last_name: 'Hatfield', email: 'andrew.hatfield@pse.com', phone: '(360)593-1578', password: random_pass()}, common_onhill_patrols_table_10[7], [:senior, :rigger, :mtr]],
 [{first_name: 'Stephanie', last_name: 'Bostwick', email: 'slbostwick@hotmail.com', phone: '(310)431-8156', password: random_pass()}, common_onhill_patrols_table_10[8], []],
 [{first_name: 'Ellen', last_name: 'Hatfield', email: 'hatfieldellen7@gmail.com', phone: '(360)599-3954', password: random_pass()}, common_onhill_patrols_table_10[9], []],
 [{first_name: 'Trevor', last_name: 'Hodge', email: 'Depuytemplates@yahoo.com', phone: '(360)483-9770', password: random_pass()}, common_onhill_patrols_table_10[10], []]
]
# # a_hosts = [
# #  [{first_name: 'Jof', last_name: 'Abshire', email: 'jof@comcast.net', phone: '(360)319-2813', password: random_pass()}, host_patrols_table[0], [:onhill, :avy2]],
# #  [{first_name: 'Csaba', last_name: 'Horvath', email: 'horcs@yahoo.com', phone: '(360)303-8456', password: random_pass()}, host_patrols_table[1], []],
# #  [{first_name: 'Tim', last_name: 'Swarens', email: 'tswarens@dawson.com', phone: '(360)296-5764', password: random_pass()}, host_patrols_table[2], []]
# # ]
a_duty_day_ids = DutyDay.where(season_id: $season_id, team_id: teams[:a]).order(date: :asc).pluck(:id) #add rotation for this season
seed_weekend(:onhill, teams[:a], a_members, a_duty_day_ids)
# #seed_members(:host, teams[:a], a_hosts, a_duty_day_ids)


# B Team
#{first_name: 'Mary', last_name: 'Davis', email: 'maryennesdavis@gmail.com', phone: '(360)224-7516', password: random_pass()}, common_onhill_patrols_table_10[0], [:mtr]],
#[{first_name: 'Katie', last_name: 'king', email: 'kaydes.13@gmail.com', phone: '(206)471-8476', password: random_pass()}, common_onhill_patrols_table[1], []],
#[{first_name: 'Ken', last_name: 'Hansen', email: 'khansen1809@gmail.com', phone: '(360)456-7890', password: random_pass()}, common_onhill_patrols_table_10[4], []],]
b_members = [
 [{first_name: 'Dan', last_name: 'Olson', email: 'wiskiguy@hotmail.com', phone: '(360)224-4182', password: random_pass()}, common_onhill_patrols_table_10[0], []],
 [{first_name: 'Kurt', last_name: 'Miller', email: 'kmilhaus@msn.com', phone: '(360)303-5978', password: random_pass()}, common_onhill_patrols_table_10[1], []],
 [{first_name: 'Miyabi', last_name: 'Gladstein', email: 'miyabiglad@yahoo.com', phone: '(360)421-5359', password: random_pass()}, common_onhill_patrols_table_10[2], [:mtr]],
 [{first_name: 'Michael', last_name: 'Hamilton', email: 'mhamiltoe@hotmail.com', phone: '(604)853-3018', password: random_pass()}, common_onhill_patrols_table_10[3], []],
 [{first_name: 'Sean', last_name: 'Gombasy', email: 'seangombasy@gmail.com', phone: '(206)830-0187', password: random_pass()}, common_onhill_patrols_table_10[4], [:avy2]],
 [{first_name: 'Olivia', last_name: 'Weeks', email: 'osweeks@gmail.com', phone: '(973)727-0249', password: random_pass()}, common_onhill_patrols_table_10[5], []],
 [{first_name: 'Chris', last_name: 'Blanchard', email: 'blanchard.ce@gmail.com', phone: '(610)608-9411', password: random_pass()}, common_onhill_patrols_table_10[6], []],
 [{first_name: 'Jack', last_name: 'Thompson', email: 'johnjackthompsonv@gmail.com', phone: '(360)306-7543', password: random_pass()}, common_onhill_patrols_table_10[7], []], 
 [{first_name: 'Corey', last_name: 'Fish', email: 'coreyafish@gmail.com', phone: '(360)391-9279', password: random_pass()}, common_onhill_patrols_table_10[8], []],
 [{first_name: 'Izzy', last_name: 'Eelnurme', email: 'izzyeelnurme@comcast.net', phone: '(425)870-4604', password: random_pass()}, common_onhill_patrols_table_10[9], []],
 [{first_name: 'Claire', last_name: 'Hoover', email: 'clairerhoover@gmail.com', phone: '(206)755-3080', password: random_pass()}, common_onhill_patrols_table_10[10], [:mtr]],
]
# #b_hosts = [
# #  [{first_name: 'Lee', last_name: 'Murray', email: 'lmillarmurray@gmail.com', phone: '(604)309-1714', password: random_pass()}, host_patrols_table[0], []],
# #  [{first_name: 'Kurt', last_name: 'Miller', email: 'kmilhaus@msn.com', phone: '(360)303-5978', password: random_pass()}, host_patrols_table[1], []],
# #  [{first_name: 'Shari', last_name: 'Miller', email: 'keepmoving4fun@yahoo.com', phone: '(360)319-1592', password: random_pass()}, host_patrols_table[2], []],
# #]
b_duty_day_ids = DutyDay.where(season_id: $season_id, team_id: teams[:b]).order(date: :asc).pluck(:id)
seed_weekend(:onhill, teams[:b], b_members, b_duty_day_ids)
# #seed_members(:host, teams[:b], b_hosts, b_duty_day_ids)


# C Team
#
#[{first_name: 'Natalie', last_name: 'Johnson', email: 'natstravels99@gmail.com', phone: '(360)647-0444', password: random_pass()}, common_onhill_patrols_table_10[2], []],
c_members = [
 [{first_name: 'Jusin', last_name: 'Mitchell', email: 'rcknice@aol.com', phone: '(360)676-9565', password: random_pass()}, common_onhill_patrols_table_10[0], [:rigger]],
 [{first_name: 'Andrea', last_name: 'Naviaux', email: 'alnaviaux@msn.com', phone: '(360)303-6622', password: random_pass()}, common_onhill_patrols_table_10[1], [:senior, :avy2]],
 [{first_name: 'Dennis', last_name: 'Larson', email: 'dennis.l.larson@comcast.net', phone: '(425)237-3492', password: random_pass()}, common_onhill_patrols_table_10[2], [:senior]],
 [{first_name: 'Forest', last_name: 'Chiavario', email: 'forestchiavario@gmail.com', phone: '(360)303-8114', password: random_pass()}, common_onhill_patrols_table_10[3], [:rigger]],
 [{first_name: 'Gunnar', last_name: 'Morin', email: 'morin.gunnar@gmail.com', phone: '(303)906-0480', password: random_pass()}, common_onhill_patrols_table_10[4], []],
 [{first_name: 'Jesse', last_name: 'Arroyo', email: 'jessewarroyo@gmail.com', phone: '(505)712-9269', password: random_pass()}, common_onhill_patrols_table_10[5], []],
 [{first_name: 'Keith', last_name: 'Poynter', email: 'keithepoynter@gmail.com', phone: '(360)410-1751', password: random_pass()}, common_onhill_patrols_table_10[6], []],
 [{first_name: 'Kirk', last_name: 'Desler', email: 'kjdesler@hotmail.com', phone: '(360)391-7818', password: random_pass()}, common_onhill_patrols_table_10[7], []],
 [{first_name: 'Matt', last_name: 'McSweyn', email: 'cooper30@gmail.com', phone: '(206)947-2172', password: random_pass()}, common_onhill_patrols_table_10[8], []],
 [nil, common_onhill_patrols_table_10[9]]
 [{first_name: 'Trevor', last_name: 'LeDain', email: 'trev4short@mac.com', phone: '(206)595-0479', password: random_pass()}, common_onhill_patrols_table_10[10], []]
]
#c_hosts = [
#  [{first_name: 'Jason', last_name: 'Perry', email: 'jasonperry0@yahoo.com', phone: '(360)223-5534', password: random_pass()}, host_patrols_table[2], []],
#]
c_duty_day_ids = DutyDay.where(season_id: $season_id, team_id: teams[:c]).order(date: :asc).pluck(:id)
seed_weekend(:onhill, teams[:c], c_members, c_duty_day_ids)
#seed_members(:host, teams[:c], c_hosts, c_duty_day_ids)

# D Team
#  [{first_name: 'Kirsten', last_name: 'Mathers', email: 'mathers.kirsten@gmail.com', phone: '(360)770-2470', password: random_pass()}, common_onhill_patrols_table[7], []],
d_members = [
  [{first_name: 'Brian', last_name: 'Black', email: 'bpblack04@mac.com', phone: '(339)987-0711', password: random_pass()}, common_onhill_patrols_table_10[0], [:rigger, :mtr, :avy2]],
  [{first_name: 'Shaun', last_name: 'Almassy', email: 'shaunalmassy@gmail.com', phone: '(360)927-5363', password: random_pass()}, common_onhill_patrols_table_10[1], [:mtr]],
  [{first_name: 'Johnny', last_name: 'Angier', email: 'angierjohnny@gmail.com', phone: '(360)527-6606', password: random_pass()}, common_onhill_patrols_table_10[2], []],
  [{first_name: 'Wayne', last_name: 'Chaudiere', email: 'chaudiere@whatcomcd.org', phone: '(360)319-7508', password: random_pass()}, common_onhill_patrols_table_10[3], []],
  [{first_name: 'Alan', last_name: 'Freysinger', email: 'ajf2417@gmail.com', phone: '(414)588-4252', password: random_pass()}, common_onhill_patrols_table_10[4], []],
  [{first_name: 'Tory', last_name: 'Hayssen', email: 'toryhayssen@gmail.com', phone: '(413)834-1330', password: random_pass()}, common_onhill_patrols_table_10[5], []],
  [{first_name: 'Tristan', last_name: 'Jones', email: 'tristanjones_@outlook.com', phone: '(425)233-0526', password: random_pass()}, common_onhill_patrols_table_10[6], []],
  [{first_name: 'Kevin', last_name: 'Kaiser', email: 'kevinrkaiser@yahoo.com', phone: '(360)319-7257', password: random_pass()}, common_onhill_patrols_table_10[7], [:rigger]],
  [{first_name: 'Brandon', last_name: 'Lee', email: 'botanicalmaple@gmail.com', phone: '(360)920-5567', password: random_pass()}, common_onhill_patrols_table_10[8], []],
  [{first_name: 'Drew', last_name: 'Sampson', email: 'drewsampson@comcast.net', phone: '(360)220-9430', password: random_pass()}, common_onhill_patrols_table_10[9], []],
  [{first_name: 'Curran', last_name: 'Wilbour', email: 'skicurran@gmail.com', phone: '(360)296-1951', password: random_pass()}, common_onhill_patrols_table_10[10], []]
]
# #d_hosts = [
# #  [{first_name: 'Ellyn', last_name: 'Erickson', email: 'redfarmar@gmail.com', phone: '(360)201-1633', password: random_pass()}, host_patrols_table[0], []],
# #  [{first_name: 'Lori', last_name: 'Bussani', email: 'bussanibunch@gmail.com', phone: '(604)857-1708', password: random_pass()}, host_patrols_table[1], [:onhill]],
# #  [{first_name: 'Todd', last_name: 'Peed', email: 'todd@nwhomes.net', phone: '(360)303-9447', password: random_pass()}, host_patrols_table[2], []],
# #  [{first_name: 'Becca', last_name: 'Steinkamp', email: 'becca@steinkamp.us', phone: '(360)303-9467', password: random_pass()}, host_patrols_table[3], []],
# #]
d_duty_day_ids = DutyDay.where(season_id: $season_id, team_id: teams[:d]).order(date: :asc).pluck(:id)
seed_weekend(:onhill, teams[:d], d_members, d_duty_day_ids)
# #seed_members(:host, teams[:d], d_hosts, d_duty_day_ids)

#host_members = [
#  [{first_name: 'Marshall', last_name: 'Seaman', email: 'marshallskis@comcast.net', phone: '(360)303-4006', password: random_pass()}, [], [:onhill]], 
#  [{first_name: 'Karen', last_name: 'Burke', email: 'karen.burke@msn.com', phone: '(360)319-6171', password: random_pass()}, [], []],
#  [{first_name: 'Marsha', last_name: 'Hanson', email: 'marshahanson@gmail.com', phone: '(507)250-0649', password: random_pass()}, [], []],
#  [{first_name: 'Judge', last_name: 'Godfrey', email: 'judgegodfrey@gmail.com', phone: '(360)303-1000', password: random_pass()}, [], []],
#  [{first_name: 'Dewey', last_name: 'Desler', email: 'ddesler@comcast.net', phone: '(360)303-3046', password: random_pass()}, [], []],
#  [{first_name: 'Phil', last_name: 'Lang', email: 'phillang'@telus.net', phone: '604)859-4646', password: random_pass()}, [], []],
#]
#seed_members(:host, teams[:host], host_members, [])

#jedd = DutyDay.where(date: [Date.new(2020, 2, 18)]).pluck(:id)
#create_patrols([User.find_by(email: 'jimevangelista55@gmail.com'), [:base]], jedd)
#kkdd = DutyDay.where(date: [Date.new(2020, 1, 14), Date.new(2019, 1, 29), Date.new(2019, 2, 11), Date.new(2019, 3, 11)]).pluck(:id)
#create_patrols([User.find_by(email: 'kelly@whidbeysunwind.com'), Array.new(4, :base)], kkdd)
#mddd = DutyDay.where(date: [Date.new(2020, 1, 15)]).pluck(:id)
#create_patrols([User.find_by(email: 'duncanmfd@gmail.com'), [:base]], mddd)

def create_sub(last, date, sub_last=nil, accepted = false)
  u = User.find_by(last_name: last)
  dd = DutyDay.find_by(date: date)
  p = Patrol.find_by(user_id: u.id, duty_day_id: dd.id)
  s = Substitution.new(user_id: u.id, patrol: p, reason: '')
  unless sub_last.nil?
      su = User.find_by(last_name: sub_last)
      s.sub_id = su.id
      s.accepted = accepted
      p.user_id = su.id
  end
  s.save(validate: false)
  p.save(validate: false)
end

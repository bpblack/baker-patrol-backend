module DataService
  module SecureRandom::RNG
    def self.rand(max)
      SecureRandom.random_number(max)
    end
  end

  def self.random_pass
    [*('a'..'z'),*('0'..'9'),*('A'..'Z')].shuffle(random: SecureRandom::RNG)[0,14].join
  end

  class SeasonData
    require 'csv'
    def initialize(first, last)
      @first = first
      @last = last
      @name = "Winter #{first.year}/#{last.year}"
      @role_resourced = {
        admin: false,
        onhill: true,
        leader: true,
        host: true,
        director: true,
        rigger: true,
        senior: false,
        avy1: false,
        avy2: false,
        mtr: false
      }
      base_role_ids = {
        admin: Role.find_by(name: :admin).id,
        onhill: Role.find_by(name: :onhill).id,
        host: Role.find_by(name: :host).id
      }
      @responsibility_ids = {
        lead: self.class.find_or_create_responsibility(name: 'Team leader', version: 15, role_id: base_role_ids[:onhill]),
        p1: self.class.find_or_create_responsibility(name: 'P1', version: 15, role_id: base_role_ids[:onhill]),
        p2: self.class.find_or_create_responsibility(name: 'P2', version: 15, role_id: base_role_ids[:onhill]),
        p3: self.class.find_or_create_responsibility(name: 'P3', version: 15, role_id: base_role_ids[:onhill]),
        p4: self.class.find_or_create_responsibility(name: 'P4', version: 15, role_id: base_role_ids[:onhill]),
        p5: self.class.find_or_create_responsibility(name: 'P5', version: 15, role_id: base_role_ids[:onhill]),
        s1: self.class.find_or_create_responsibility(name: 'S1', version: 15, role_id: base_role_ids[:onhill]),
        s2: self.class.find_or_create_responsibility(name: 'S2', version: 15, role_id: base_role_ids[:onhill]),
        s3: self.class.find_or_create_responsibility(name: 'S3', version: 15, role_id: base_role_ids[:onhill]),
        s4: self.class.find_or_create_responsibility(name: 'S4', version: 15, role_id: base_role_ids[:onhill]),
        s5: self.class.find_or_create_responsibility(name: 'S5', version: 15, role_id: base_role_ids[:onhill]),
        mw1: self.class.find_or_create_responsibility(name: 'Midweek 1', version: 15, role_id: base_role_ids[:onhill]),
        mw2: self.class.find_or_create_responsibility(name: 'Midweek 2', version: 15, role_id: base_role_ids[:onhill]),
        mw3: self.class.find_or_create_responsibility(name: 'Midweek 3', version: 15, role_id: base_role_ids[:onhill]),
        mw4: self.class.find_or_create_responsibility(name: 'Midweek 4', version: 15, role_id: base_role_ids[:onhill]),
        h1: self.class.find_or_create_responsibility(name: 'Host 1', version: 1, role_id: base_role_ids[:host]),
        h2: self.class.find_or_create_responsibility(name: 'Host 2', version: 1, role_id: base_role_ids[:host]),
        h3: self.class.find_or_create_responsibility(name: 'Host 3', version: 1, role_id: base_role_ids[:host]),
        h4: self.class.find_or_create_responsibility(name: 'Host 4', version: 1, role_id: base_role_ids[:host]),
        #base: find_or_create_responsibility(name: 'Base', version: 15, role_id: base_role_ids[:onhill])
      }
      @teams = {
        trainer: Team.find_by(name: 'Trainer Team').id,
        midweek: Team.find_by(name: 'Midweek Team').id,
        a: Team.find_by(name: 'A Team').id,
        b: Team.find_by(name: 'B Team').id,
        c: Team.find_by(name: 'C Team').id,
        d: Team.find_by(name: 'D Team').id,
        host: Team.find_by(name: 'Host Team').id,
      }
      #load the midweek patrols from csv
      @midweek_patrols = self.class.load_patrol_csv('config/subs/midweek_patrols.csv')
      @midweek_patrols += @midweek_patrols #duplicate for the second team in the roster
      @midweek_patrols.unshift(Array.new(@midweek_patrols[0].length * 2, :lead)) #double the leader duties 
      #load the weekend patrols from csv
      @weekend_patrols = self.class.load_patrol_csv('config/subs/weekend_patrols.csv')
      @weekend_patrols.unshift(Array.new(@weekend_patrols[0].length, :lead))
      #load the host patrols from csv
      @host_patrols = self.class.load_patrol_csv('config/subs/host_patrols.csv')
      #load the roster form json
      @roster = ActiveSupport::JSON.decode(File.read('config/subs/roster.json'))
      puts @roster
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
        Patrol.create!(user_id: uid, duty_day_id: user_duty_resp[0], patrol_responsibility_id: @responsibility_ids[user_duty_resp[1]])
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
            r = RosterSpot.create!(user_id: user.id, team_id: team_id, season_id: @season_id)
            created = true
          else
            r = user.season_roster_spot(@season_id)
            if r.nil?
              r = RosterSpot.create!(user_id: user.id, team_id: team_id, season_id: @season_id)
            end
          end
          add_extra_roles(user, r, member[2])
          member[0] = user
          member[0].add_role(role, r) unless member[0].has_role?(role, r)
        end
        create_patrols(member, team_duty_day_ids) unless member[1].nil?
        if created
         email_new_user(member[0])
        end
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
        r = RosterSpot.create!(user_id: user.id, team_id: team_id, season_id: @season_id)
        created = true
      else
        r = user.season_roster_spot(@season_id)
        if r.nil?
          r = RosterSpot.create!(user_id: user.id, team_id: team_id, season_id: @season_id)
        end
      end
      add_extra_roles(user, r, leader[2])
      leader[0] = user
      leader[0].add_role(role, r)
      leader[0].add_role(:leader, r)
      create_patrols(leader, team_duty_day_ids)
      if created
       email_new_user(leader[0])
      end
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
        if @role_resourced[role]
          user.add_role(role, roster_spot) unless user.has_role?(role, roster_spot)
        else
          user.add_role(role) unless user.has_role?(role)
        end
      end
    end
    
    def mapRoster(team_roster, patrol_table)
      team_roster.each_with_index.map do |m, i| 
        [m.nil? ? nil : {first_name: m[0], last_name: m[1], email: m[2], phone: m[3], password: DataService::random_pass}, patrol_table[i], m[4].nil? ? [] : m[4].map{ |e| e.to_sym}]
      end
    end 

    def seed()
      ActiveRecord::Base.transaction do
        # create the season
        puts "Creating #{@name} season..."
        @season_id = Season.create!(name: @name, start: @first, end: @last).id
        # create the duty days
        puts "Creating duty days..."
        patrol_teams = [@teams[:midweek], @teams[:a], @teams[:b], @teams[:midweek], @teams[:c], @teams[:d]]
        (@first..@last).filter_map { |x| x if (x.friday? || x.saturday? || x.sunday?) }.zip(patrol_teams.cycle).each do |dd|
          DutyDay.create!(season_id: @season_id, date: dd[0], team_id: dd[1])
        end
        #seed trainers
        puts "Seeding Trainer team..."
        seed_members(:onhill, @teams[:trainer], mapRoster(@roster['trainer'], []), [])
        #seed midweek
        puts "Seeding Midweek team..."
        midweek = @teams[:midweek]
        midweek_duty_day_ids = DutyDay.where(season_id: @season_id, team_id: midweek).order(date: :asc).pluck(:id)
        seed_midweek(:onhill, midweek, mapRoster(@roster['midweek'], @midweek_patrols), midweek_duty_day_ids)
        #seed a
        puts "Seeding A team..."
        a = @teams[:a]
        a_duty_day_ids = DutyDay.where(season_id: @season_id, team_id: a).order(date: :asc).pluck(:id) #add rotation for this season
        seed_weekend(:onhill, a, mapRoster(@roster['a'], @weekend_patrols), a_duty_day_ids)
        seed_members(:host, a, mapRoster(@roster['a_hosts'], @host_patrols), a_duty_day_ids)
        #seed b
        puts "Seeding B team..."
        b = @teams[:b]
        b_duty_day_ids = DutyDay.where(season_id: @season_id, team_id: b).order(date: :asc).pluck(:id)
        seed_weekend(:onhill, b, mapRoster(@roster['b'], @weekend_patrols), b_duty_day_ids)
        seed_members(:host, b, mapRoster(@roster['b_hosts'], @host_patrols), b_duty_day_ids)
        #seed c
        puts "Seeding C team..."
        c = @teams[:c]
        c_duty_day_ids = DutyDay.where(season_id: @season_id, team_id: c).order(date: :asc).pluck(:id)
        seed_weekend(:onhill, c, mapRoster(@roster['c'], @weekend_patrols), c_duty_day_ids)
        seed_members(:host, c, mapRoster(@roster['c_hosts'], @host_patrols), c_duty_day_ids)
        #seed d
        puts "Seeding D team..."
        d = @teams[:d]
        d_duty_day_ids = DutyDay.where(season_id: @season_id, team_id: d).order(date: :asc).pluck(:id)
        seed_weekend(:onhill, d, mapRoster(@roster['d'], @weekend_patrols), d_duty_day_ids)
        seed_members(:host, d, mapRoster(@roster['d_hosts'], @host_patrols), d_duty_day_ids)
        puts "#{@name} seeding completed!"
        #only for testing
      rescue ActiveRecord::RecordInvalid => e
        puts "FAILED to seed: #{e.message}"
      end
    end

    # example generate(Date.new(2023, 11, 10), Date.new(2024, 4, 21), 'Winter 2023/2024')
    def self.generate(first, last)
      obj = SeasonData.new(first, last)
      obj.seed
    end

    def self.find_or_create_responsibility(name:, version:, role_id:)
      pr = PatrolResponsibility.find_by(name: name)
      if pr.nil?
        pr_id = PatrolResponsibility.create!(name: name, version: version, role_id: role_id).id
      else
        pr_id = pr.id
      end
      pr_id
    end

    def self.load_patrol_csv(name)
      x = []
      CSV.foreach(name) { |row| x << (row.map { |e| e.strip.to_sym})}
      return x
    end
  end
  
  class CprData
    def initialize()
    end

    def seed()
    end

    def self.generate()
    end
  end
end
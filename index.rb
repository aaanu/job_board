require 'json'

class JobBoard
    attr_accessor :jobs

    def initialize
    @input = "Lead Chef, Chipotle, Denver, CO, 10, 15
    Stunt Double, Equity, Los Angeles, CA, 15, 25
    Manager of Fun, IBM, Albany, NY, 30, 40
    Associate Tattoo Artist, Tit 4 Tat, Brooklyn, NY, 250, 275
    Assistant to the Regional Manager, IBM, Scranton, PA, 10, 15
    Lead Guitarist, Philharmonic, Woodstock, NY, 100, 200"

    @jobs = []

    array_of_jobs = @input.split("\n")
    
    array_of_jobs.each do |job|
        job_details = job.strip.split(", ")
        title = job_details[0]
        organization = job_details[1]
        city = job_details[2]
        state = job_details[3]
        pay_min = job_details[4]
        pay_max = job_details[5]
        @jobs.push(JobListing.new(title, organization, city, state, pay_min, pay_max))
    end
    end

    def sort_by_title
        sorted_jobs = @jobs.sort_by do |job_listing|
            job_listing.title
        end
        sorted_jobs
    end

    def get_ny_jobs
        ny_jobs = @jobs.select{|job_listing| job_listing.state == "NY"}.sort_by do |job_listing|
            job_listing.title
        end
        ny_jobs
    end

    def find_by_title(title)
        result = nil
        @jobs.each do |job|
            if job.title == title
                result = job
            end
        end
        result
    end
end

class JobListing
    attr_accessor :title, :organization, :city, :state, :pay_min, :pay_max
    def initialize(title, organization, city, state, pay_min, pay_max)
        @title = title
        @organization = organization
        @city = city
        @state = state
        @pay_min = pay_min
        @pay_max = pay_max
    end

    def to_s
        "Title: #{@title}, Organization: #{@organization}, Location: #{@city}, #{@state}, Pay: #{@pay_min}-#{@pay_max}"
    end
end

class JobBoard_FastStateLookup
    attr_accessor :jobs

    def initialize
        @input = "Lead Chef, Chipotle, Denver, CO, 10, 15
    Stunt Double, Equity, Los Angeles, CA, 15, 25
    Manager of Fun, IBM, Albany, NY, 30, 40
    Associate Tattoo Artist, Tit 4 Tat, Brooklyn, NY, 250, 275
    Assistant to the Regional Manager, IBM, Scranton, PA, 10, 15
    Lead Guitarist, Philharmonic, Woodstock, NY, 100, 200"

    # Searching by keys in a hash is an O(1) lookup
    @jobs = Hash.new

    array_of_jobs = @input.split("\n")
    array_of_jobs.each do |job|
        job_details = job.strip.split(", ")
        title = job_details[0]
        organization = job_details[1]
        city = job_details[2]
        state = job_details[3]
        pay_min = job_details[4]
        pay_max = job_details[5]
        @jobs[title] = JobListing.new(title, organization, city, state, pay_min, pay_max)
    end

    end

    def find_by_title(title)
        @jobs[title]
    end

    def sort_by_title
        sorted = @jobs.sort.to_h
        sorted
    end

    def get_ny_jobs
        ny_jobs = @jobs.select{|k,v| v.state == "NY"}.sort.to_h
        ny_jobs
    end
end

class JobBoard_NewInput < JobBoard_FastStateLookup
    attr_accessor :jobs

    def initialize
        @input = 'Lead Chef, Chipotle, Denver, CO, 10, 15
        Stunt Double, Equity, Los Angeles, CA, 15, 25
        Manager of Fun, IBM, Albany, NY, 30, 40
        Associate Tattoo Artist, Tit 4 Tat, Brooklyn, NY, 250, 275
        Assistant to the Regional Manager, IBM, Scranton, PA, 10, 15
        Lead Guitarist, Philharmonic, Woodstock, NY, 100, 200
        --JSON FORMAT BELOW--
        {"name": "Spaceship Repairman", "location": {"city": "Olympus Mons", "state": "Mars"}, "organization": "Interplanetary Enterprises", "pay": {"min": 100, "max": 200}}
        {"name": "State Park Ranger", "location": {"city": "Ray Brook", "state": "NY"}, "organization": "Adirondack Park Agency", "pay": {"min": 40, "max": 50}}
        {"name": "Lead Cephalopod Caretaker", "location": {"city": "Atlantis", "state": "Oceania"}, "organization": "Deep Adventures", "pay": {"min": 10, "max": 15}}'

        @jobs = Hash.new
        split_jobs = @input.split(/--JSON FORMAT BELOW--/)
        jobs_string = split_jobs[0]
        jobs_json = split_jobs[1]

        array_of_jobs = jobs_string.split("\n")
        
        array_of_jobs.each do |job|
            job_details = job.strip.split(", ")
            if job_details[0].nil?
                break
            end
            title = job_details[0]
            organization = job_details[1]
            city = job_details[2]
            state = job_details[3]
            pay_min = job_details[4]
            pay_max = job_details[5]
            @jobs[title] = JobListing.new(title, organization, city, state, pay_min, pay_max)
        end

        additional_jobs = jobs_json.strip.split("\n")
        additional_jobs.each do |job|
            parsed_job = JSON.parse(job)
            title = parsed_job["name"]
            organization = parsed_job["organization"]
            city = parsed_job["location"]["city"]
            state = parsed_job["location"]["state"]
            pay_min = parsed_job["pay"]["min"]
            pay_max = parsed_job["pay"]["max"]
            @jobs[title] = JobListing.new(title, organization, city, state, pay_min, pay_max)
        end
    end

    def find_keyword(keyword)
        found = @jobs.select{|k,v| v.to_s.include? keyword}.sort.to_h
    end

end
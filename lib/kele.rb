require "httparty"
require "json"
require "./lib/roadmap"

class Kele
    include HTTParty
    include Roadmap
    
    def initialize(email, password)
        response = self.class.post(base_api_endpoint("sessions"), body: { "email": email, "password": password })
        @auth_token = response["auth_token"]
        if response.code == 401
            now[:alert] = "There was an error creating your username or password."
        end
        
    end
    
    def get_me
        response = self.class.get(base_api_endpoint("users/me"), headers: { "authorization" => @auth_token })
        @user_data = JSON.parse(response.body)
    end
    
    def get_mentor_availability(mentor_id)
        response = self.class.get(base_api_endpoint("mentors/#{mentor_id}/student_availability"), headers: { "authorization" => @auth_token })
        @mentor_availability = [response.body]
    end
    
    def get_messages(*page)
        if page.empty?
            x = 1
            @messages = []
            response = self.class.get(base_api_endpoint("message_threads"), headers: { "authorization" => @auth_token })
            while x <= response.count
                @messages.push(self.class.get(base_api_endpoint("message_threads?page=#{x}"), headers: { "authorization" => @auth_token }))
                x += 1
            end
        puts @messages
            
        else
            response = self.class.get(base_api_endpoint("message_threads?page=#{page.join}"), headers: { "authorization" => @auth_token })
            @messages = [response.body]
            
        end
    end
    
    def create_message(sender, recipient_id, token, subject, body)
        self.class.post(base_api_endpoint("messages"), headers: { "authorization" => @auth_token }, body: {sender: sender, recipient_id: recipient_id, token: token, subject: subject, body: body})
    end
    
    def create_submission(assignment_branch, assignment_commit_link, checkpoint_id, comment, enrollment_id)
        self.class.post(base_api_endpoint("checkpoint_submissions"), headers: { "authorization" => @auth_token }, body: {assignment_branch: assignment_branch, assignment_commit_link: assignment_commit_link, checkpoint_id: checkpoint_id, comment: comment, enrollment_id: enrollment_id})
    end

    private
    
    def base_api_endpoint(end_point)
        "https://www.bloc.io/api/v1/#{end_point}"
    end
end
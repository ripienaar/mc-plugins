#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'mcollective'
require 'lib/exim.rb'
require 'cgi'

class EximWeb < Sinatra::Base
    def initialize
        @exim = Exim.new
        super
    end

    set :static, true
    set :public, "public"

    helpers do
        include Rack::Utils
        alias_method :h, :escape_html

        def sanitize_email(email)
            email.gsub!(/^</, "")
            email.gsub!(/>$/, "")

            if email == ""
                email = "postmaster"
            end

            return email
        end

        def display_result(result)
            if result.is_a?(String)
                result.split("\n").map{|r| h(r)}.join("<br>")
            elsif result.is_a?(Numeric)
                result.to_s
            else
                "<pre>" + h(JSON.pretty_generate(result)) + "</pre>"
            end
        end

        def label_for_code(code)
            case code
                when 0
                    '<span class="label success">ok</span>'
                when 1
                    '<span class="label warning">aborted</span>'
                when 2
                    '<span class="label warning">unknown action</span>'
                when 3
                    '<span class="label warning">missing data</span>'
                when 4
                    '<span class="label warning">invalid data</span>'
                when 5
                    '<span class="label warning">unknown error</span>'
            end
        end
    end

    get '/mailq' do
        @mailq = @exim.mailq

        erb :mailq_view
    end

    get '/mailq/thaw/:id' do
        @action = "thaw"
        @ddl = @exim.ddl
        @results = []

        unless params[:id] =~ /^\w+-\w+-\w+$/
            @error = "#{params[:id]} is not a valid message id"
        else
            @results = @exim.thaw(params[:id])
        end

        erb :generic_result_view
    end

    get '/mailq/freeze/:id' do
        @action = "freeze"
        @ddl = @exim.ddl
        @results = []

        unless params[:id] =~ /^\w+-\w+-\w+$/
            @error = "#{params[:id]} is not a valid message id"
        else
            @results = @exim.freeze(params[:id])
        end

        erb :generic_result_view
    end

    get '/mailq/run' do
        @action = "runq"
        @ddl = @exim.ddl
        @results = @exim.runq

        erb :generic_result_view
    end

    get '/mailq/delete/frozen' do
        @action = "rmfrozen"
        @ddl = @exim.ddl
        @results = @exim.rmfrozen

        erb :generic_result_view
    end

    get '/mailq/delete/bounces' do
        @action = "rmbounces"
        @ddl = @exim.ddl
        @results = @exim.rmbounces

        erb :generic_result_view
    end

    get '/mailq/delete/:id' do
        @action = "rm"
        @ddl = @exim.ddl
        @results = []

        unless params[:id] =~ /^\w+-\w+-\w+$/
            @error = "#{params[:id]} is not a valid message id"
        else
            @results = @exim.rm(params[:id])
        end

        erb :generic_result_view
    end

    get '/mailq/retrymsg/:id' do
        @action = "retrymsg"
        @ddl = @exim.ddl
        @results = []

        unless params[:id] =~ /^\w+-\w+-\w+$/
            @error = "#{params[:id]} is not a valid message id"
        else
            @results = @exim.retrymsg(params[:id])
        end

        erb :generic_result_view
    end

    get '/exiwhat' do
        @action = "exiwhat"
        @ddl = @exim.ddl
        @results = @exim.exiwhat
        erb :generic_result_view
    end

    get '/size' do
        @action = "size"
        @ddl = @exim.ddl
        @results = @exim.size
        erb :generic_result_view
    end
end

EximWeb.run!

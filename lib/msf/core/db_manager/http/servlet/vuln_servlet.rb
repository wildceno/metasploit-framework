module VulnServlet

  def self.api_path
    '/api/v1/vulns'
  end

  def self.api_path_with_id
    "#{VulnServlet.api_path}/?:id?"
  end

  def self.registered(app)
    app.get VulnServlet.api_path_with_id, &get_vuln
    app.post VulnServlet.api_path, &report_vuln
    app.put VulnServlet.api_path_with_id, &update_vuln
    app.delete VulnServlet.api_path, &delete_vuln
  end

  #######
  private
  #######

  def self.get_vuln
    lambda {
      begin
        opts = parse_json_request(request, false)
        data = get_db().vulns(params.symbolize_keys)
        includes = [:host]
        set_json_response(data, includes)
      rescue Exception => e
        set_error_on_response(e)
      end
    }
  end

  def self.report_vuln
    lambda {
      begin
        job = lambda { |opts|
          get_db().report_vuln(opts)
        }
        exec_report_job(request, &job)
      rescue Exception => e
        set_error_on_response(e)
      end
    }
  end

  def self.update_vuln
    lambda {
      begin
        opts = parse_json_request(request, false)
        tmp_params = params.symbolize_keys
        opts[:id] = tmp_params[:id] if tmp_params[:id]
        data = get_db().update_vuln(opts)
        set_json_response(data)
      rescue Exception => e
        set_error_on_response(e)
      end
    }
  end

  def self.delete_vuln
    lambda {
      begin
        opts = parse_json_request(request, false)
        data = get_db().delete_vuln(opts)
        set_json_response(data)
      rescue Exception => e
        set_error_on_response(e)
      end
    }
  end

end
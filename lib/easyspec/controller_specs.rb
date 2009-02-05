module EasySpec
  module ControllerSpecs
    def self.included(base)
      base.send(:extend, ModuleMethods)
      base.send(:include, InstanceMethods)
    end

    module ModuleMethods
      def should_normally_succeed(&params_meth)
        should_have_response 200
      end

      def should_have_response(status, &params_meth)
        it "should be a #{status}" do
          params_meth ||= default_paramz
          @method ||= :get
          send @method.to_sym, @action, params_meth.call
          response.headers["Status"].to_i.should == status
        end
      end

      def should_succeed_with_format(format)
        it "should be a success with format #{format}" do
          params_meth ||= default_paramz
          @method ||= :get
          send @method.to_sym, @action, params_meth.call.merge(:format => format)
          response.should be_success
        end
      end

      def should_redirect(redirect_params=nil)
        it "should redirect" do
          params_meth ||= default_paramz
          @method ||= :get
          send @method.to_sym, @action, params_meth.call
          if redirect_params
            response.should redirect_to(redirect_params)
          else
            response.should be_redirect
          end
        end
      end

      def should_assign(name, val=nil, &params_meth)
        it "should assign #{name}" do
          params_meth ||= default_paramz
          @method ||= :get
          send @method.to_sym, @action, params_meth.call
          if val = instance_variable_get("@#{name}")
            val.should_not be_nil
            assigns(name.to_sym).should == val
          else
            assigns(name.to_sym).should_not be_nil
          end
        end
      end

      def should_paginate(name, opts={})
        it "should return the default number of #{name}" do
          pending if opts[:pending]
          count = V1::RestController::DEFAULT_LIMIT
          send "make_more_#{name}", count
          get 'index', paramz
          assigns(name.to_sym).size.should == count
        end

        it "should respect pagination args for #{name}" do
          pending if opts[:pending]
          count = V1::RestController::DEFAULT_LIMIT
          send "make_more_#{name}", count
          get 'index', paramz.merge(:limit => 2, :offset => 1)
          ivar = instance_variable_get("@#{name}")
          paginated = begin
                        ivar.find_visible_to(nil, :all, :limit => 2, :offset => 1)
                      rescue
                        paginated_meth(2, 1)
                      end
          assigns(name.to_sym).map(&:id).should == paginated.map(&:id)
        end
      end

      def should_400_without(param, &params_meth)
        should_have_response_without("400 Bad Request", param, params_meth)
      end

      def should_401_without(param, &params_meth)
        should_have_response_without("401 Unauthorized", param, params_meth)
      end

      def should_404_without(param, &params_meth)
        should_have_response_without("404 Not Found", param, params_meth) do |response|
          response.body.should =~ /#{param[/(.*)_id/, 1]}/
        end
      end

      def should_422_without(param, &params_meth)
        should_have_response_without("422 Unprocessable Entity", param, params_meth)
      end

      def should_have_response_without(resp, param, params_meth)
        it "should be #{resp} without #{param}" do
          params_meth ||= default_paramz
          @method ||= :get
          send @method.to_sym, @action, params_meth.call.merge(param.to_sym => nil)
          response.headers['Status'].should == resp
          yield response if block_given?
        end
      end
    end

    module InstanceMethods
      def default_paramz
        lambda { defined?(paramz) ? paramz : {} }
      end
    end
  end
end

Spec::Rails::Example::ControllerExampleGroup.send :include, EasySpec::ControllerSpecs


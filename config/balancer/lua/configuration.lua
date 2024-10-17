local endpoints_data = ngx.shared.endpoints_data
local cjson = require("cjson.safe")

local _M = {}

local function fetch_body()         
  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  return body
end

local function check_none(endpoints)
  if string.match(endpoints, "none") then
	  return true
  end
end

function _M.get_backends_data()
    return endpoints_data:get("backends")
end

function _M.handle_endpoints()
    local value = endpoints_data:get("backends")
    
    print("[BALANCER.HANDLER]: New endpoints update request income")
    print(ngx.var.request_method)
    if ngx.var.request_method ~= "POST" and ngx.var.request_method ~= "GET" then
      ngx.status = ngx.HTTP_BAD_REQUEST                                                  
      ngx.print("[BALANCER.HANDLER]: Only POST and GET requests are allowed!")
      return                                                                   
    end
  
    local endpoints = fetch_body()
    if not endpoints then                                                                             
       ngx.log(ngx.ERR, "[BALANCER.HANDLER]: look's like body empty. Unable to read valid request body")                   
       ngx.status = ngx.HTTP_BAD_REQUEST                                                              
       return                                                                                         
    end 
    print(endpoints)
    
    local none_status = check_none(endpoints)
      
    if none_status then
       print("[BALANCER.HANDLER]: Empty endpoint table is come, seting backends to none")
       local none_endpoints = '[{"address": "none"}]'
       local success, err = endpoints_data:set("backends", none_endpoints)
       if not success then
          ngx.log(ngx.ERR, "[BALANCER.HANDLER]: dynamic-configuration: error updating configuration: " .. tostring(err))
          ngx.status = ngx.HTTP_BAD_REQUEST
          return
       end
    else
       local success, err = endpoints_data:set("backends", endpoints)
       if not success then
          ngx.log(ngx.ERR, "[BALANCER.HANDLER]: dynamic-configuration: error updating configuration: " .. tostring(err))
          ngx.status = ngx.HTTP_BAD_REQUEST
          return
       end
    end
    
    ngx.status = ngx.HTTP_CREATED
end

return _M
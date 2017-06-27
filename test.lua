local mysql = require "resty.mysql"

local exit = ngx.exit

local mysql_host = ngx.var.mysql_host
local mysql_port = ngx.var.mysql_port
local mysql_database = ngx.var.mysql_database
local mysql_user = ngx.var.mysql_user
local mysql_password = ngx.var.mysql_password

local id = ngx.var.arg_id

local db, err = mysql:new()
if not db then
    ngx.log(ngx.STDERR, err)
    exit(500)
end

db:set_timeout(3000)

local ok, err, errcode, sqlstate = db:connect{
    host = mysql_host,
    port = mysql_port,
    database = mysql_database,
    user = mysql_user,
    password = mysql_password,
    charset = "utf8mb4",
    max_packet_size = 1024 * 1024,
}

if not ok then
    ngx.log(ngx.STDERR, err)
    exit(500)
end

local quoted_id = ngx.quote_sql_str(id)
local sql = "SELECT `status` FROM `demo` WHERE `id` = " .. quoted_id

res, err, errcode, sqlstate = db:query(sql)

if err then
    ngx.log(ngx.STDERR, err)
    exit(500)
end

if not res[1] then
    return
end

exit(tonumber(res[1]["status"]))

use strict;
use warnings;

use Test::Nginx::Socket;
use DBI;
use Test::mysqld;
use Test::More;

my $mysqld = Test::mysqld->new(
    my_cnf => {
        'port' => '3306',
    }
) or plan skip_all => $Test::mysqld::errstr;

my $dbh = DBI->connect(
    $mysqld->dsn(dbname => 'test'),
);

$dbh->do("CREATE TABLE `demo` (
  `id` int unsigned NOT NULL,
  `status` varchar(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

$dbh->do("INSERT INTO `demo` (`id`, `status`) VALUES (?,?)", undef, 1, "200");
$dbh->do("INSERT INTO `demo` (`id`, `status`) VALUES (?,?)", undef, 2, "418");

run_tests();

done_testing();

__DATA__


=== TEST: ファイルを置いたら見える
--- config
    location /test.txt {
        root html;
    }
--- user_files
>>> test.txt
testtest
--- request
    GET /test.txt
--- error_code: 200
--- response_body
testtest

=== TEST: mysqlにidがあればステータスコードになる
--- config
    location /demo.jpg {
        root html;

        set $mysql_host "127.0.0.1";
        set $mysql_port "3306";
        set $mysql_database "test";
        set $mysql_user "root";
        set $mysql_password "";

        access_by_lua_file /usr/src/app/test.lua;
    }
--- user_files
>>> demo.jpg
testtest
--- request
    GET /demo.jpg?id=2
--- error_code: 418
--- response_body

=== TEST: mysqlにidがなければ普通に動く
--- config
    location /demo.jpg {
        root html;

        set $mysql_host "127.0.0.1";
        set $mysql_port "3306";
        set $mysql_database "test";
        set $mysql_user "root";
        set $mysql_password "";

        access_by_lua_file /usr/src/app/test.lua;
    }
--- user_files
>>> demo.jpg
testtest
--- request
    GET /demo.jpg?id=10
--- error_code: 200
--- response_body
testtest

# by vxkxxxxxx

use strict;
use warnings;
use Mojolicious::Lite -signatures;

my $out_file = "./tgusernames.txt";
my @freelinks;
my @links;

my $usage = qq{

    Запуск: perl xk.pl [ ФАЙЛ С ССЫЛКАМИ ИЛИ ССЫЛКИ ЧЕРЕЗ ПРОБЕЛ ]
    Запись в файл $out_file

    Пример: perl xk.pl mylinks.txt
    Пример: perl xk.pl link1 link2 ..
    
    Ссылки, которые будут рабоать:
    link
    \@link
    http://t.me/link
    https://t.me/link
    t.me/link
    
    Статусы:
        SOLD            продано
        TAKEN           занято
        AVAILABLE       доступно к продаже
        ON AUTION       покупается в данный момент
        UNAVAILABLE     доступно
        
};

die $usage unless @ARGV;

sub end {
    if (@freelinks) {
        open F, ">>", $out_file;
        say F "\n" . localtime . "\n";
        say F for @freelinks;
    }
    die
}

$SIG{INT} = \&end;

sub clink {
    chomp;
    s!http(s)?://!!i;
    s!t\.me/!!;
    s/@//;
    push @links, $_
}


if (-e $ARGV[0]) { &clink while <> }
else { &clink($_) for @ARGV }

my $ua = Mojo::UserAgent->new;

for (@links) {
    my $res = $ua->get('https://fragment.com/?query=' . $_)->result;
    if ($res->is_success) {
        if ($res->body =~ 
            m[
                <div\sclass="table-cell-value\stm-value">\@$_
                </div>(?:\n|\s?)*
                <div\sclass="table-cell-status-thin
                \sthin-only\stm-status-\w*">
                (
                        (Unavailable)
                    |   (Available)
                    |   (On\sauction)
                    |   (Sold)
                    |   (Taken)
                )
                </div>
            ]x)
        {
            my $L = "[ \U$1\E ]\t\t$_";
            say $L;
            push @freelinks, $L;
        }
        else { say 'tf' }
    }
}
&end

#!/usr/bin/env perl

use LWP::Simple;
use HTML::TreeBuilder::XPath;
use Switch;

sub pageRequest {
    my ($url) = @_;

    my $content = get $url;
    die "Can't fetch url $url\n" unless defined $content;
    return $content;
}

sub findXPath {
    my ($xml,$xpath) = @_;

    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse($xml);
    my @nodeset = $tree->findnodes($xpath);
    return @nodeset;
}

sub extractOggStream {
    my ($content) = @_;
    my @playercontrol = findXPath($content,'//div[@id="playercontrol"]/div[@class="block"]/a[position()=2');
    my $streampath = @playercontrol[0]->attr('href');
    return $streampath;
}

sub getMainPageContent {
    my $tagesschaumain = 'http://www.tagesschau.de';
    my $content = pageRequest($tagesschaumain);
    return $content;
}

sub findLast20Url {
    my $content = getMainPageContent();
    my @nodes = findXPath($content,'//select[@id="navSendungen"]');
    my $url = @nodes[0]->content()->[0]->attr('value');
    return $url;

}

sub findLast20Stream {
    my $flashpageurl = findLast20Url();
    my $flashpage = pageRequest($flashpageurl);
    my $streampath = extractOggStream($flashpage);
    return $streampath;
}

sub findLiveStream {
    return "http://www.tagesschau.de/commons/include/multimedia/style_video_wmv_live_cover.jsp?res=high&typ=1"
}

sub findRecentUrl {
    my $content = getMainPageContent();
    my @lastshownode = findXPath($content,'//div[@id="sendungenLeft"]/ul/li[position()=3]/a');
    my $lastshowurl = @lastshownode[0]->attr('href');
    return $lastshowurl;
}

sub findRecentStream {
    my $recentpageurl = findRecentUrl();
    my $recentpage = pageRequest($recentpageurl);
    my $streampath = extractOggStream($recentpage);
    return $streampath;
}

sub mplayerPlay {
    my ($url) = @_;
    exec("mplayer '$url'");
}

my ($toplay) = @ARGV;
my $url;

print "toplay:$toplay\n";
if (!$toplay) {
    $url = findLast20Stream();
}else {
    switch($toplay) {
        case "live" {
            $url = findLiveStream();
        }
        case "recent" {
            $url = findRecentStream();
        }
    }
}

mplayerPlay($url);
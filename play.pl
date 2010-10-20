#!/usr/bin/env perl

use LWP::Simple;
use HTML::TreeBuilder::XPath;

sub pageRequest {
    if(@_ < 1) {
        print "not enough parameter in pageRequest\n";
        return;
    }

    my $url = @_[0];
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

sub findFlashPage {
    my $tagesschaumain = 'http://www.tagesschau.de';
    my $content = pageRequest($tagesschaumain);
    my @nodes = findXPath($content,'//select[@id="navSendungen"]');
    my $url = @nodes[0]->content()->[0]->attr('value');
    return $url;

}

sub findStreamUrl {
    my $flashpageurl = findFlashPage();
    print "Current URL:$flashpageurl \n";
    my $flashpage = pageRequest($flashpageurl);
    my @playercontrol = findXPath($flashpage,'//div[@id="playercontrol"]/div[@class="block"]/a[position()=2');
    my $streampath = @playercontrol[0]->attr('href');
    print "Stream Path: $streampath\n";
    return $streampath;
}

sub mplayerPlay {
    my ($url) = @_;
    exec("mplayer '$url'");
}

mplayerPlay(findStreamUrl());

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.util.HashSet;

public class SiteCrawl implements MigratableProcess {
    HashSet<String> visited = new HashSet<String>();
    String siteRoot;

    String lastUrl;
    int depth;

    private volatile boolean suspending;

    public SiteCrawl(String[] args) {
        this.siteRoot = args[0];
        this.suspending = false;
        this.depth = 1;
    }

    /* count number of pages reachable from this.siteRoot */
    public void count() {
        this.lastUrl = "http://"+this.siteRoot;
        this.count("http://"+this.siteRoot);
    }

    /* count number of pages reachable from the given page not already visited */
    private void count(String url) {
        if (!suspending) {
            Document doc = null;
            try {
                lastUrl = url;
                /* do extra requests to test migration safety */
                doc = Jsoup.connect(url).get();
                doc = Jsoup.connect(url).get();
                doc = Jsoup.connect(url).get();
                doc = Jsoup.connect(url).get();
            } catch (IOException e){
                System.out.println("Could not connect");
                System.exit(1);
            } catch (IllegalArgumentException e) {
                return;
            }
            Elements links = doc.getElementsByTag("a");

            for (Element link : links) {
                String linkHref = link.attr("href");
                String linkText = link.text();
                System.out.printf("\nhref=\"%s\"", linkHref);
            }
            for (Element link : links) {
                String href = link.attr("href");
                if (this.depth > 50 || this.visited.contains(href) || !href.contains(this.siteRoot)) {
                } else {
                    System.out.println("RECURSING");
                    this.visited.add(href);
                    this.depth ++;
                    this.count(href);
                }
            }
        }
        suspending = false;
    }

    public void run () {
        this.count();
    }

    public void suspend() {
        this.suspending = true;
        while(suspending);
    }

    public static void main (String[] args) {
        SiteCrawl p = new SiteCrawl(args);
        p.run();
    }
}

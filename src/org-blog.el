;;; org-blog.el --- Blog with ox-publish          -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Narendra Joshi

;; Author: Narendra Joshi <narendraj9@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org project configuration my personal blog.

;;; Code:

(require 'org)
(require 'ox-publish)
(require 'ox-html)
(require 'org-element)
(require 'ox-rss)

(defvar org-blog-date-format "%h %d, %Y"
  "Format for displaying publish dates.")

(defun org-blog-prepare (project-plist)
  "With help from `https://github.com/howardabrams/dot-files'.
  Touch `index.org' to rebuilt it.
  Argument `PROJECT-PLIST' contains information about the current project."
  (let* ((base-directory (plist-get project-plist :base-directory))
         (buffer (find-file-noselect (expand-file-name "index.org" base-directory) t)))
    (with-current-buffer buffer
      (set-buffer-modified-p t)
      (save-buffer 0))
    (kill-buffer buffer)))

(defvar org-blog-head
  "
  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
  <meta name=\"description\" content=\"TODO: description\" />
  <meta name=\"keywords\" content=\"HTML, CSS, JavaScript, PHP\" />
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1\">

  <link rel=\"shortcut icon\" href=\"images/favicon.png\" />
  <link href='http://fonts.googleapis.com/css?family=Montserrat:400,700%7CLibre+Baskerville:400,400italic,700' rel='stylesheet' type='text/css'>
  <link rel=\"stylesheet\" type=\"text/css\"  href='/assets/css/clear.css' />
  <link rel=\"stylesheet\" type=\"text/css\"  href='/assets/css/common.css' />
  <link rel=\"stylesheet\" type=\"text/css\"  href='/assets/css/font-awesome.min.css' />
  <link rel=\"stylesheet\" type=\"text/css\"  href='/assets/css/carouFredSel.css' />
  <link rel=\"stylesheet\" type=\"text/css\"  href='/assets/css/sm-clean.css' />
  <link rel=\"stylesheet\" type=\"text/css\"  href='/assets/css/suppablog.css' />
  <link rel=\"stylesheet\" type=\"text/css\"  href='/assets/css/custom.css' />
  ")

(defun org-blog-preamble (plist)
  "Pre-amble for whole blog."
  ;; Hack! Put date for the post as the subtitle
  (when (s-contains-p "/posts/" (plist-get plist :input-file))
    (plist-put plist
               :subtitle (format "Published on %s"
                                 (org-export-get-date plist
                                                      org-blog-date-format))))
    "

    <!-- Preloader Gif -->
    <table class=\"doc-loader\">
        <tbody>
            <tr>
                <td>
                    <img src=\"images/ajax-document-loader.gif\" alt=\"Loading...\">
                </td>
            </tr>
        </tbody>
    </table>

    <!-- Left Sidebar -->
    <div id=\"sidebar\" class=\"sidebar\">
        <div class=\"menu-left-part\">
            <!-- <div class=\"search-holder\">
                  <label>
                  <input type=\"search\" class=\"search-field\" placeholder=\"Type here to search...\" value=\"\" name=\"s\" title=\"Search for:\">
                  </label>
                  </div> -->
            <div class=\"site-info-holder\">
                <div class=\"site-title\">TODO: Title</div>
                <p class=\"site-description\">
                    TODO: Description
                </p>
            </div>
            <nav id=\"header-main-menu\">
                <ul class=\"main-menu sm sm-clean\">
                    <li><a href=\"scroll.html\">Posts</a></li>
                    <li><a href=\"about.html\">About me</a></li>
                </ul>
            </nav>
            <footer>
                <div class=\"footer-info\">
                    © 2018 SUPPABLOG HTML TEMPLATE. <br> CRAFTED WITH <i class=\"fa fa-heart\"></i> BY <a href=\"https://colorlib.com\">COLORLIB</a>.
                </div>
            </footer>
        </div>
        <div class=\"menu-right-part\">
            <div class=\"logo-holder\">
                <a href=\"index.html\">
                    <img src=\"images/logo.png\" alt=\"Suppablog WP\">
                </a>
            </div>
            <div class=\"toggle-holder\">
                <div id=\"toggle\">
                    <div class=\"menu-line\"></div>
                </div>
            </div>
            <div class=\"social-holder\">
                <div class=\"social-list\">
                    <!-- <a href=\"#\"><i class=\"fa fa-twitter\"></i></a>
                          <a href=\"#\"><i class=\"fa fa-youtube-play\"></i></a>
                          <a href=\"#\"><i class=\"fa fa-facebook\"></i></a>
                          <a href=\"#\"><i class=\"fa fa-vimeo\"></i></a>
                          <a href=\"#\"><i class=\"fa fa-behance\"></i></a> -->
                    <a href=\"#\"><i class=\"fa fa-rss\"></i></a>
                    <a href=\"#\"><i class=\"fa fa-github\"></i></a>
                </div>
            </div>
            <div class=\"fixed scroll-top\"><i class=\"fa fa-caret-square-o-up\" aria-hidden=\"true\"></i></div>
        </div>
        <div class=\"clear\"></div>
    </div>

    <!-- Single Content -->
    <div id=\"content\" class=\"site-content center-relative\">
    <div class=\"single-post-wrapper content-1070 center-relative\">

        <article class=\"center-relative\">")

(defun org-blog-postamble (plist)
  "Post-amble for whole blog."
  (concat
   "
            </article>
        </div>
    </div>



    <!--Load JavaScript-->
    <script type=\"text/javascript\" src=\"/assets/js/jquery.js\"></script>
    <script type='text/javascript' src='/assets/js/imagesloaded.pkgd.js'></script>
    <script type='text/javascript' src='/assets/js/jquery.nicescroll.min.js'></script>
    <script type='text/javascript' src='/assets/js/jquery.smartmenus.min.js'></script>
    <script type='text/javascript' src='/assets/js/jquery.carouFredSel-6.0.0-packed.js'></script>
    <script type='text/javascript' src='/assets/js/jquery.mousewheel.min.js'></script>
    <script type='text/javascript' src='/assets/js/jquery.touchSwipe.min.js'></script>
    <script type='text/javascript' src='/assets/js/jquery.easing.1.3.js'></script>
    <script type='text/javascript' src='/assets/js/main.js'></script>"

   (when nil "<!-- Google Analytics -->
  <script async src=\"https://www.googletagmanager.com/gtag/js?id=UA-55966581-1\"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'UA-55966581-1');
  </script>")

   (when nil "<script type=\"text/javascript\" src=\"/assets//assets/js/custom.js\"> </script>
  <script type=\"text/javascript\" src=\"//downloads.mailchimp.com//assets/js/signup-forms/popup/embed.js\" data-dojo-config=\"usePlainJson: true, isDebug: false\"></script><script type=\"text/javascript\">require([\"mojo/signup-forms/Loader\"], function(L) { L.start({\"baseUrl\":\"mc.us18.list-manage.com\",\"uuid\":\"7e6d10e32e5355f05a9b343de\",\"lid\":\"420dab7107\"}) })</script> ")

   ;; DISABLED
   ;; Add Disqus if it's a post
   (when (and nil (s-contains-p "/posts/" (plist-get plist :input-file)))
     "
  <div id=\"disqus_thread\"></div>
  <script type=\"text/javascript\">
   var disqus_shortname = 'vicarie';
   (function() {
     var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
     dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
     (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
   })();
  </script>
  <noscript>Please enable JavaScript to view the <a href=\"http://disqus.com/?ref_noscript\">comments powered by Disqus.</a></noscript>
  ")))


(defun org-blog-sitemap-format-entry (entry _style project)
  "Return string for each ENTRY in PROJECT."
  (when (s-starts-with-p "posts/" entry)
    (format "@@html:<span class=\"archive-item\"><span class=\"archive-date\">@@ %s @@html:</span>@@ [[file:%s][%s]] @@html:</span>@@"
            (format-time-string org-blog-date-format
                                (org-publish-find-date entry project))
            entry
            (org-publish-find-title entry project))))

(defun org-blog-sitemap-function (title list)
  "Return sitemap using TITLE and LIST returned by `org-blog-sitemap-format-entry'."
  (concat "#+TITLE: " title "\n\n"
          "\n#+begin_archive\n"
          (mapconcat (lambda (li)
                       (format "@@html:<li>@@ %s @@html:</li>@@" (car li)))
                     (seq-filter #'car (cdr list))
                     "\n")
          "\n#+end_archive\n"))

(defun org-blog-publish-to-html (plist filename pub-dir)
  "Same as `org-html-publish-to-html' but modifies html before finishing."
  (let ((file-path (org-html-publish-to-html plist filename pub-dir)))
    (save-window-excursion
      (with-current-buffer (find-file-noselect file-path)
        (goto-char (point-min))
        (search-forward "<body>" nil t)
        (replace-match "<body class=\"single-post\">")
        (insert (concat "\n<div class=\"content-wrapper container\">\n "
                        "  <div class=\"row\"> <div class=\"col\"> </div> "
                        "  <div class=\"col-sm-12 col-md-10 col-lg-10\"> "))
        (goto-char (point-max))
        (search-backward "</body>")
        (insert "\n</div>\n<div class=\"col\"></div></div>\n</div>\n")
        (save-buffer)
        (kill-buffer)))
    file-path))


(setq org-publish-project-alist
      `(("orgfiles"
         :base-directory "~/dev/blog/src/"
         :exclude ".*drafts/.*"
         :base-extension "org"

         :publishing-directory "~/dev/blog/"

         :recursive t
         :preparation-function org-blog-prepare
         :publishing-function org-blog-publish-to-html

         :with-toc nil
         :with-title t
         :with-date t
         :section-numbers nil
         :html-doctype "html5"
         :html-html5-fancy t
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :htmlized-source t
         :html-head-extra ,org-blog-head
         :html-preamble org-blog-preamble
         :html-postamble org-blog-postamble

         :auto-sitemap t
         :sitemap-filename "archive.org"
         :sitemap-title "Blog Posts"
         :sitemap-style list
         :sitemap-sort-files anti-chronologically
         :sitemap-format-entry org-blog-sitemap-format-entry
         :sitemap-function org-blog-sitemap-function)

        ("assets"
         :base-directory "~/dev/blog/src/assets/"
         :base-extension ".*"
         :publishing-directory "~/dev/blog/assets/"
         :publishing-function org-publish-attachment
         :recursive t)

        ("rss"
         :base-directory "~/dev/blog/src/"
         :base-extension "org"
         :html-link-home "https://bilus.dev/"
         :html-link-use-abs-url t
         :rss-extension "xml"
         :publishing-directory "~/dev/blog/"
         :publishing-function (org-rss-publish-to-rss)
         :exclude ".*"
         :include ("archive.org")
         :section-numbers nil
         :table-of-contents nil)

        ("blog" :components ("orgfiles" "assets" "rss"))))

(provide 'org-blog)
;;; org-blog.el ends here

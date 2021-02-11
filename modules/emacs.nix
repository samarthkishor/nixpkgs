{ config, pkgs, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball
    "https://github.com/nix-community/NUR/archive/master.tar.gz") { };

in {

  imports = [ nur-no-pkgs.repos.rycee.hmModules.emacs-init ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  programs.emacs.init = {
    enable = true;
    recommendedGcSettings = true;

    earlyInit = ''
      ;; Disable some GUI distractions. We set these manually to avoid starting
      ;; the corresponding minor modes.
      (push '(menu-bar-lines . 0) default-frame-alist)
      (push '(tool-bar-lines . nil) default-frame-alist)
      (push '(vertical-scroll-bars . nil) default-frame-alist)

      ;; Set up fonts early.
      (set-face-attribute 'default
                          nil
                          :height 140
                          :family "Iosevka"
                          :weight 'normal)
      (set-face-attribute 'variable-pitch
                          nil
                          :height 140
                          :family "Iosevka Etoile")
    '';

    prelude = ''
        ;; Disable startup message.
        (setq inhibit-startup-screen t
              inhibit-startup-echo-area-message (user-login-name))

        (setq initial-major-mode 'fundamental-mode
              initial-scratch-message nil)

        ;; Set frame title.
        (setq frame-title-format
              '("" invocation-name ": "(:eval
                                        (if (buffer-file-name)
                                            (abbreviate-file-name (buffer-file-name))
                                          "%b"))))

        ;; Stop creating backup and autosave files.
        (setq make-backup-files nil
              auto-save-default nil)

        ;; Typically, I only want spaces when pressing the TAB key. I also
        ;; want 4 of them.
        (setq-default indent-tabs-mode nil
                      tab-width 4
                      c-basic-offset 4)

        ;; Trailing white space are banned!
        (setq-default show-trailing-whitespace t)

        ;; I typically want to use UTF-8.
        (prefer-coding-system 'utf-8)

        ;; Nicer handling of regions.
        (transient-mark-mode 1)

        ;; Make moving cursor past bottom only scroll a single line rather
        ;; than half a page.
        (setq scroll-step 1
              scroll-conservatively 5)

        ;; Enable highlighting of current line.
        (global-hl-line-mode 1)

        ;; When finding file in non-existing directory, offer to create the
        ;; parent directory.
        (defun with-buffer-name-prompt-and-make-subdirs ()
          (let ((parent-directory (file-name-directory buffer-file-name)))
            (when (and (not (file-exists-p parent-directory))
                       (y-or-n-p (format "Directory `%s' does not exist! Create it? " parent-directory)))
              (make-directory parent-directory t))))

        (add-to-list 'find-file-not-found-functions #'with-buffer-name-prompt-and-make-subdirs)

      ;; Remap keys
      (when (eq system-type 'darwin)
        (setq mac-option-modifier 'meta
          mac-command-modifier 'control
          mac-control-modifier 'super
          mac-right-command-modifier 'super
          mac-right-option-modifier 'none))
    '';

    usePackage = {
      autorevert = {
        enable = true;
        diminish = [ "auto-revert-mode" ];
        command = [ "auto-revert-mode" ];
      };

      # needs rg to be installed (which is handled by the home-manager config)
      deadgrep = {
        enable = true;
        bind = { "C-x f" = "deadgrep"; };
      };

      dired = {
        enable = true;
        command = [ "dired" "dired-jump" ];
        config = ''
          (put 'dired-find-alternate-file 'disabled nil)
          ;; Use the system trash can.
          (setq delete-by-moving-to-trash t)
          (setq dired-listing-switches "-alvh --group-directories-first")
        '';
      };

      doom-modeline = {
        enable = true;
        hook = [ "(after-init . doom-modeline-mode)" ];
        config = ''
          (setq doom-modeline-buffer-file-name-style 'truncate-except-project)
        '';
      };

      doom-themes = { enable = true; };

      modus-operandi-theme = {
        enable = true;
        config = ''
          (setq modus-operandi-theme-prompts 'intense)
          (setq modus-operandi-theme-completions 'opinionated)
          (setq modus-operandi-theme-org-blocks 'greyscale)
          (setq modus-operandi-theme-scale-headings t)

          (load-theme 'modus-operandi t)
          ;; Without it tables becomes missaligned
          (set-face-attribute 'button nil :inherit '(fixed-pitch))
        '';
      };

      modus-vivendi-theme = {
        enable = true;
        config = ''
          (setq modus-operandi-theme-prompts 'intense)
          (setq modus-operandi-theme-completions 'opinionated)
          (setq modus-operandi-theme-org-blocks 'greyscale)
          (setq modus-operandi-theme-scale-headings t)

          ;; Without it tables becomes missaligned
          (set-face-attribute 'button nil :inherit '(fixed-pitch))
        '';
      };

      eldoc = {
        enable = true;
        diminish = [ "eldoc-mode" ];
        command = [ "eldoc-mode" ];
      };

      # Enable Electric Indent mode to do automatic indentation on RET.
      electric = {
        enable = true;
        command = [ "electric-indent-local-mode" ];
        hook = [
          "(prog-mode . electric-indent-mode)"

          # Disable for some modes.
          "(nix-mode . (lambda () (electric-indent-local-mode -1)))"
        ];
      };

      etags = {
        enable = true;
        defer = true;
        # Avoid spamming reload requests of TAGS files.
        config = "(setq tags-revert-without-query t)";
      };

      evil = {
        enable = true;
        init = ''
          (setq evil-want-integration nil)
        '';
        config = ''
          (defun prelude-shift-left-visual ()
            "Shift left and restore visual selection."
            (interactive)
            (evil-shift-left (region-beginning) (region-end))
            (evil-normal-state)
            (evil-visual-restore))
          (defun prelude-shift-right-visual ()
            "Shift right and restore visual selection."
            (interactive)
            (evil-shift-right (region-beginning) (region-end))
            (evil-normal-state)
            (evil-visual-restore))
          (setq evil-want-fine-undo t)
          (setq evil-shift-width 2)
          (setq evil-want-abbrev-expand-on-insert-exit nil)
          (define-key evil-visual-state-map (kbd ">") 'prelude-shift-right-visual)
          (define-key evil-visual-state-map (kbd "<") 'prelude-shift-left-visual)
          (evil-define-key nil evil-normal-state-map
            "j" 'evil-next-visual-line
            "k" 'evil-previous-visual-line)
          (evil-declare-key 'normal org-mode-map
            "gk" 'outline-up-heading
            "gj" 'outline-next-visible-heading
            (kbd "TAB") 'org-cycle
            "$" 'org-end-of-line ; smarter behavior on headlines etc.
            "^" 'org-beginning-of-line ; ditto
            "-" 'org-ctrl-c-minus ; change bullet style
            "<" 'org-metaleft ; out-dent
            ">" 'org-metaright) ; indent
          ;; Use Emacs state in these additional modes.
          (dolist (mode '(ag-mode
                          custom-mode
                          custom-new-theme-mode
                          dired-mode
                          eshell-mode
                          flycheck-error-list-mode
                          git-rebase-mode
                          org-capture-mode
                          term-mode
                          deadgrep-mode))
            (add-to-list 'evil-emacs-state-modes mode))

          (evil-mode 1)
        '';
      };

      evil-surround = {
        enable = true;
        after = [ "evil" ];
        diminish = [ "global-evil-surround-mode" ];
        hook = [
          ''
            (c++-mode . (lambda () (push '(?< . ("< " . " >")) evil-surround-pairs-alist)))''
        ];
        config = ''
          (global-evil-surround-mode 1)
        '';
      };

      flyspell = {
        enable = true;
        diminish = [ "flyspell-mode" ];
        command = [ "flyspell-mode" "flyspell-prog-mode" ];
        hook = [
          # Spell check in text and programming mode.
          "(text-mode . flyspell-mode)"
          "(prog-mode . flyspell-prog-mode)"
        ];
        config = ''
          ;; In flyspell I typically do not want meta-tab expansion
          ;; since it often conflicts with the major mode. Also,
          ;; make it a bit less verbose.
          (setq flyspell-issue-message-flag nil
                flyspell-issue-welcome-flag nil
                flyspell-use-meta-tab nil)
        '';
      };

      ggtags = {
        enable = true;
        defer = true;
        diminish = [ "ggtags-mode" ];
        command = [ "ggtags-mode" ];
      };

      ispell = {
        enable = true;
        defer = 1;
      };

      olivetti = {
        enable = true;
        config = ''
          (setq olivetti-body-width 0.7)
          (setq olivetti-minimum-body-width 80)
          (setq olivetti-recall-visual-line-mode-entry-state t)
        '';
      };

      # Remember where we where in a previously visited file. Built-in.
      saveplace = {
        enable = true;
        defer = 1;
        config = ''
          (setq-default save-place t)
          (setq save-place-file (locate-user-emacs-file "places"))
        '';
      };

      undo-tree = {
        enable = true;
        defer = 1;
        diminish = [ "undo-tree-mode" ];
        command = [ "global-undo-tree-mode" ];
        config = ''
          (setq undo-tree-visualizer-relative-timestamps t
                undo-tree-visualizer-timestamps t
                undo-tree-enable-undo-in-region t)
          (global-undo-tree-mode)
        '';
      };

      ibuffer = {
        enable = true;
        hook = [ "(ibuffer-mode-hook . hl-line-mode)" ];
        bind = { "C-x C-b" = "ibuffer"; };
        bindLocal = {
          ibuffer-mode-map = {
            "* f" = "ibuffer-mark-by-file-name-regexp";
            "/ g" = "ibuffer-filter-by-content"; # "g" is for "grep"
            "* g" = "ibuffer-mark-by-content-regexp";
            "* n" = "ibuffer-mark-by-name-regexp";
            "s n" = "ibuffer-do-sort-by-alphabetic";
          };
        };
        config = ''
          (setq ibuffer-expert t)
          (setq ibuffer-display-summary nil)
          (setq ibuffer-use-other-window nil)
          (setq ibuffer-movement-cycle nil)
          (setq ibuffer-default-sorting-mode 'filename/process)
          (setq ibuffer-use-header-line t)
          (setq ibuffer-default-shrink-to-minimum-size nil)
          (setq ibuffer-formats
            '((mark modified read-only locked " "
                (name 30 30 :left :elide)
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " " filename-and-process)
              (mark " "
                (name 16 -1)
                " " filename)))
        '';
      };

      # More helpful buffer names. Built-in.
      uniquify = {
        enable = true;
        defer = 5;
        config = ''
          (setq uniquify-buffer-name-style 'post-forward)
        '';
      };

      hippie-exp = {
        enable = true;
        bind = { "M-?" = "hippie-expand"; };
      };

      writeroom-mode = {
        enable = true;
        command = [ "writeroom-mode" ];
        bindLocal = {
          writeroom-mode-map = {
            "M-[" = "writeroom-decrease-width";
            "M-]" = "writeroom-increase-width";
            "M-'" = "writeroom-toggle-mode-line";
          };
        };
        hook = [ "(writeroom-mode . visual-line-mode)" ];
        config = ''
          (setq writeroom-bottom-divider-width 0)
        '';
      };

      ## Buffer/Frame/Window Management

      buffer-move = {
        enable = true;
        bind = {
          "C-S-<up>" = "buf-move-up";
          "C-S-<down>" = "buf-move-down";
          "C-S-<left>" = "buf-move-left";
          "C-S-<right>" = "buf-move-right";
        };
      };

      # Enable winner mode. This global minor mode allows you to
      # undo/redo changes to the window configuration. Uses the
      # commands C-c <left> and C-c <right>.
      winner = {
        enable = true;
        defer = 2;
        config = "(winner-mode 1)";
      };

      ## Completion

      which-key = {
        enable = true;
        command = [
          "which-key-mode"
          "which-key-add-major-mode-key-based-replacements"
        ];
        diminish = [ "which-key-mode" ];
        defer = 3;
        config = "(which-key-mode)";
      };

      ivy = {
        enable = true;
        demand = true;
        diminish = [ "ivy-mode" ];
        command = [ "ivy-mode" ];
        config = ''
          (setq ivy-use-virtual-buffers t
                ivy-count-format "%d/%d "
                ivy-virtual-abbreviate 'full)

          (ivy-mode 1)
        '';
      };

      ivy-hydra = {
        enable = true;
        defer = true;
        after = [ "ivy" "hydra" ];
      };

      ivy-xref = {
        enable = true;
        after = [ "ivy" "xref" ];
        command = [ "ivy-xref-show-xrefs" ];
        config = ''
          (setq xref-show-xrefs-function #'ivy-xref-show-xrefs)
        '';
      };

      swiper = {
        enable = true;
        command = [ "swiper" "swiper-all" "swiper-isearch" ];
        bind = { "C-s" = "swiper-isearch"; };
      };

      # Lets counsel do prioritization. A fork of smex.
      amx = {
        enable = true;
        command = [ "amx-initialize" ];
      };

      counsel = {
        enable = true;
        bind = {
          "C-x C-d" = "counsel-dired-jump";
          "C-x C-f" = "counsel-find-file";
          "C-x M-f" = "counsel-fzf";
          "C-x C-r" = "counsel-recentf";
          "C-x C-y" = "counsel-yank-pop";
          "M-x" = "counsel-M-x";
        };
        diminish = [ "counsel-mode" ];
        config = let
          fd = "${pkgs.fd}/bin/fd";
          fzf = "${pkgs.fzf}/bin/fzf";
          rg = "${pkgs.ripgrep}/bin/rg";
        in ''
          (setq counsel-fzf-cmd "${fd} --type f | ${fzf} -f \"%s\"")
          (setq counsel-rg-base-command (list "${rg}" "-M" "240" "--with-filename" "--no-heading" "--line-number" "--color" "never" "%s"))
        '';
      };

      ## Org-mode

      org = {
        enable = true;
        package = epkgs: epkgs.org-plus-contrib;
        bind = {
          "C-c o c" = "org-capture";
          "C-c o a" = "org-agenda";
          "C-c o l" = "org-store-link";
          "C-c o b" = "org-switchb";
        };
        hook = [''
          (org-mode
           . (lambda ()
               (add-hook 'completion-at-point-functions
                         'pcomplete-completions-at-point nil t)))
        ''];
        config = let xelatex = "xelatex";
        in ''
          (setq org-directory "~/Dropbox/org/")

          (defun tasks ()
            "Open main tasks file and start 'org-agenda' for this week."
            (interactive)
            (find-file (concat org-directory "tasks.org"))
            (org-agenda-list)
            (org-agenda-week-view)
            (shrink-window-if-larger-than-buffer)
            (other-window 1))

          (defun homework ()
            "Open homework file and start 'org-agenda' for this week."
            (interactive)
            (find-file (concat org-directory "homework.org"))
            (org-agenda-list)
            (org-agenda-week-view)
            (shrink-window-if-larger-than-buffer)
            (other-window 1))

          ;; Some general stuff.
          (setq org-reverse-note-order t
                org-use-fast-todo-selection t
                org-adapt-indentation nil
                org-hide-leading-stars t
                org-hide-emphasis-markers t)

          ;; Add some todo keywords.
          (setq org-todo-keywords
                '((sequence "TODO(t)"
                            "STARTED(s!)"
                            "WAITING(w@/!)"
                            "DELEGATED(@!)"
                            "|"
                            "DONE(d!)"
                            "CANCELED(c@!)")))

          ;; Setup org capture.

          ;; Active Org-babel languages
          (org-babel-do-load-languages 'org-babel-load-languages
                                       '((http . t)
                                         (shell . t)
                                         (python . t)))

          ;; Unfortunately org-mode tends to take over keybindings that
          ;; start with C-c.
          (unbind-key "C-c SPC" org-mode-map)
          (unbind-key "C-c w" org-mode-map)

          ;; Configure PDF exports
          (setq org-latex-pdf-process '("${xelatex} -shell-escape %f" "biber %b" "${xelatex} -shell-escape %f" "${xelatex} -shell-escape %f"))
        '';
      };

      ox-hugo = {
        enable = true;
        after = [ "ox" ];
      };

      org-agenda = {
        enable = true;
        after = [ "org" ];
        defer = true;
        config = ''
          ;; Set up agenda view.
          (setq org-agenda-files (list
                                   (concat org-directory "tasks.org")
                                   (concat org-directory "refile-beorg.org")
                                   (concat org-directory "homework.org"))
                org-agenda-span 5
                org-deadline-warning-days 14
                org-agenda-show-all-dates t
                org-agenda-skip-deadline-if-done t
                org-agenda-skip-scheduled-if-done t)
        '';
      };

      org-clock = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq org-clock-rounding-minutes 5
                org-clock-out-remove-zero-time-clocks t)
        '';
      };

      org-duration = {
        enable = true;
        after = [ "org" ];
        config = ''
          ;; I always want clock tables and such to be in hours, not days.
          (setq org-duration-format (quote h:mm))
        '';
      };

      # org-refile = {
      #   enable = true;
      #   after = [ "org" ];
      #   config = ''
      #     ;; Refiling should include not only the current org buffer but
      #     ;; also the standard org files. Further, set up the refiling to
      #     ;; be convenient with IDO. Follows norang's setup quite closely.
      #     (setq org-refile-targets '((nil :maxlevel . 2)
      #                                (org-agenda-files :maxlevel . 2))
      #           org-refile-use-outline-path t
      #           org-outline-path-complete-in-steps nil
      #           org-refile-allow-creating-parent-nodes 'confirm)
      #   '';
      # };

      org-variable-pitch = {
        enable = false;
        hook = [ "(org-mode . org-variable-pitch-minor-mode)" ];
      };

      ob-http = {
        enable = true;
        after = [ "org" ];
        defer = true;
      };

      ## General Programming

      company = {
        enable = true;
        diminish = [ "company-mode" ];
        command = [ "company-mode" "company-doc-buffer" "global-company-mode" ];
        defer = 1;
        extraConfig = ''
          :bind (:map company-mode-map
                      ([remap completion-at-point] . company-complete-common)
                      ([remap complete-symbol] . company-complete-common))
        '';
        config = ''
          (setq company-idle-delay 0.3
                company-show-numbers t
                company-tooltip-maximum-width 100
                company-tooltip-minimum-width 20
                ; Allow me to keep typing even if company disapproves.
                company-require-match nil)
          (global-company-mode)
        '';
      };

      direnv = {
        enable = true;
        command = [ "direnv-mode" "direnv-update-environment" ];
      };

      magit = {
        enable = true;
        bind = { "C-c g" = "magit-status"; };
        config = ''
          (setq magit-completing-read-function 'ivy-completing-read)
          (add-to-list 'git-commit-style-convention-checks
                       'overlong-summary-line)
        '';
      };

      magit-diff = {
        enable = true;
        after = [ "magit" ];
        config = ''
          (setq magit-diff-refine-hunk t)
        '';
      };

      edit-indirect.enable = true;

      markdown-mode = {
        enable = true;
        defer = true;
        config = ''
          (setq markdown-fontify-code-blocks-natively t)
        '';
        mode = [ ''("\\.md$" . markdown-mode)'' ];
      };

      pandoc-mode = {
        enable = true;
        after = [ "markdown-mode" ];
        hook = [ "markdown-mode" ];
        bindLocal = {
          markdown-mode-map = { "C-c C-c" = "pandoc-run-pandoc"; };
        };
      };

      nix-sandbox = {
        enable = true;
        command = [ "nix-current-sandbox" "nix-shell-command" ];
      };

      format-all = {
        enable = true;
        bindLocal = { prog-mode-map = { "<f6>" = "format-all-buffer"; }; };
      };

      smartparens = {
        enable = true;
        defer = 3;
        diminish = [ "smartparens-mode" ];
        command = [ "smartparens-global-mode" "show-smartparens-global-mode" ];
        bindLocal = {
          smartparens-mode-map = {
            "C-M-f" = "sp-forward-sexp";
            "C-M-b" = "sp-backward-sexp";
          };
        };
        config = ''
          (require 'smartparens-config)
          (smartparens-global-mode t)
          (show-smartparens-global-mode t)
          (sp-use-paredit-bindings)

          (defun my-create-newline-and-enter-sexp (&rest _ignored)
            "Open a new brace or bracket expression, with relevant newlines and indent. "
            (newline)
            (indent-according-to-mode)
            (forward-line -1)
            (indent-according-to-mode))
          (setq sp-escape-quotes-after-insert nil)
          (sp-local-pair 'c++-mode "{" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))
          (sp-local-pair 'c-mode "{" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))
          (sp-local-pair 'java-mode "{" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))
          (sp-local-pair 'web-mode "{" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))
          (sp-local-pair 'typescript-mode "{" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))
          (sp-local-pair 'js-mode "{" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))
        '';
      };

      fill-column-indicator = {
        enable = true;
        command = [ "fci-mode" ];
      };

      flycheck = {
        enable = true;
        diminish = [ "flycheck-mode" ];
        command = [ "global-flycheck-mode" ];
        defer = 1;
        bind = {
          "M-n" = "flycheck-next-error";
          "M-p" = "flycheck-previous-error";
        };
        config = ''
          ;; Only check buffer when mode is enabled or buffer is saved.
          (setq flycheck-check-syntax-automatically '(mode-enabled save))

          ;; Enable flycheck in all eligible buffers.
          (global-flycheck-mode)
        '';
      };

      projectile = {
        enable = true;
        diminish = [ "projectile-mode" ];
        command = [ "projectile-mode" "projectile-project-root" ];
        bindKeyMap = { "C-c p" = "projectile-command-map"; };
        config = ''
          (setq projectile-enable-caching t
                projectile-completion-system 'ivy)
          (projectile-mode 1)
        '';
      };

      lsp-ivy = {
        enable = true;
        after = [ "lsp-mode" ];
        command = [ "lsp-ivy-workspace-symbol" ];
      };

      lsp-ui = {
        enable = true;
        command = [ "lsp-ui-mode" ];
        bindLocal = {
          lsp-mode-map = {
            "C-c r d" = "lsp-ui-doc-glance";
            "C-c f s" = "lsp-ui-find-workspace-symbol";
          };
        };
        config = ''
          (setq lsp-ui-sideline-enable t
                lsp-ui-sideline-show-symbol nil
                lsp-ui-sideline-show-hover nil
                lsp-ui-sideline-show-code-actions nil
                lsp-ui-sideline-update-mode 'point)
          (setq lsp-ui-doc-enable nil
                lsp-ui-doc-position 'at-point
                lsp-ui-doc-max-width 120
                lsp-ui-doc-max-height 15)
        '';
      };

      lsp-ui-flycheck = {
        enable = true;
        after = [ "flycheck" "lsp-ui" ];
      };

      lsp-completion = {
        enable = true;
        after = [ "lsp-mode" ];
        config = ''
          (setq lsp-completion-enable-additional-text-edit nil)
        '';
      };

      lsp-diagnostics = {
        enable = true;
        after = [ "lsp-mode" ];
      };

      lsp-mode = {
        enable = true;
        command = [ "lsp" ];
        after = [ "company" "flycheck" ];
        hook = [ "(lsp-mode . lsp-enable-which-key-integration)" ];
        bindLocal = {
          lsp-mode-map = {
            "C-c r r" = "lsp-rename";
            "C-c r f" = "lsp-format-buffer";
            "C-c r a" = "lsp-execute-code-action";
            "C-c f r" = "lsp-find-references";
          };
        };
        init = ''
          (setq lsp-keymap-prefix "C-c l")
        '';
        config = ''
          (setq lsp-diagnostics-provider :flycheck
                lsp-eldoc-render-all nil
                lsp-headerline-breadcrumb-enable nil
                lsp-modeline-code-actions-enable nil
                lsp-modeline-diagnostics-enable nil)
          (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
        '';
      };

      dap-mode = {
        enable = true;
        after = [ "lsp-mode" ];
      };

      dap-mouse = {
        enable = true;
        hook = [ "(dap-mode . dap-tooltip-mode)" ];
      };

      dap-ui = {
        enable = true;
        hook = [ "(dap-mode . dap-ui-mode)" ];
      };

      ## Languages

      elpy = {
        enable = true;
        defer = true;
        config = ''
          (when-let (ipython (executable-find "ipython"))
            (setq python-shell-interpreter ipython
                  python-shell-interpreter-args "-i --simple-prompt"))
        '';
      };

      lean-mode = {
        enable = true;
      };

      prolog = {
        hook = [ ''("\\.pl\\'" . prolog-mode)'' ];
        config = ''
          (setq prolog-system 'swi)

          (when (executable-find "swipl")
            (setq prolog-program-name `((swi ,(executable-find "swipl")) (t "pl"))))
        '';
      };

      js = {
        enable = true;
        mode = [ ''("\\.js\\'" . js-mode)'' ''("\\.json\\'" . js-mode)'' ];
        config = ''
          (setq js-indent-level 2)
        '';
      };

      nix-mode = {
        enable = true;
        hook = [ "(nix-mode . subword-mode)" ];
      };

      # Configure AUCTeX.
      # latex = {
      #   enable = true;
      #   package = epkgs: epkgs.auctex;
      #   mode = [ ''("\\.tex\\'" . latex-mode)'' ];
      #   config = ''
      #     (setq TeX-PDF-mode t
      #           TeX-auto-save t
      #           TeX-parse-self t)
      #     ;; Add Glossaries command. See
      #     ;; http://tex.stackexchange.com/a/36914
      #     (eval-after-load "tex"
      #       '(add-to-list
      #         'TeX-command-list
      #         '("Glossaries"
      #           "makeglossaries %s"
      #           TeX-run-command
      #           nil
      #           t
      #           :help "Create glossaries file")))
      #   '';
      # };

      # Setup RefTeX.
      reftex = {
        enable = true;
        defer = true;
        config = ''
          (setq reftex-cite-format 'natbib
                reftex-plug-into-AUCTeX t)
        '';
      };

      ### Emacs applications

      # mu4e for email
      mu4e = {
        enable = true;
        command = [ "mu4e" ];
        config = ''
          ;; Load the library
          (let ((mu4e-location
                    (if (eq system-type 'darwin)
                        "/usr/local/share/emacs/site-lisp/mu/mu4e"
                        "/home/samarth/.nix-profile/share/emacs/site-lisp/mu4e/")))
            (add-to-list 'load-path mu4e-location))
          (require 'mu4e)

          (setq mu4e-maildir (expand-file-name "~/Maildir"))
          (setq mu4e-get-mail-command "${pkgs.isync}/bin/mbsync -a")
          (setq mu4e-change-filenames-when-moving t) ;; fix for mbsync
          ;; Enable inline images.
          (setq mu4e-view-show-images t)
          (setq mu4e-view-image-max-width 800)
          ;; Use imagemagick, if available.
          (when (fboundp 'imagemagick-register-types)
            (imagemagick-register-types))

          ;; Show email addresses as well as names.
          (setq mu4e-view-show-addresses t)

          ;; Open email in a browser if necessary.
          (add-to-list 'mu4e-view-actions '("View in browser" . mu4e-action-view-in-browser) t)

          ;; This hook correctly modifies the \Inbox and \Starred flags on email when they are marked to trigger the appropriate Gmail actions.
          (add-hook 'mu4e-mark-execute-pre-hook
            (lambda (mark msg)
              (cond ((member mark '(refile trash)) (mu4e-action-retag-message msg "-\\Inbox"))
                    ((equal mark 'flag) (mu4e-action-retag-message msg "\\Starred"))
                    ((equal mark 'unflag) (mu4e-action-retag-message msg "-\\Starred")))))

          ;; Helper functions
          (defun mu4e-message-maildir-matches (msg rx)
            "Determine which account context I am in based on the maildir subfolder"
            (when rx
                (if (listp rx)
                    ;; If rx is a list, try each one for a match
                    (or (mu4e-message-maildir-matches msg (car rx))
                        (mu4e-message-maildir-matches msg (cdr rx)))
                ;; Not a list, check rx
                (string-match rx (mu4e-message-field msg :maildir)))))

          (defun choose-msmtp-account ()
            "Choose account label to feed msmtp -a option based on From header
            in Message buffer; This function must be added to
            message-send-mail-hook for on-the-fly change of From address before
            sending message since message-send-mail-hook is processed right
            before sending message."
            (if (message-mail-p)
                (save-excursion
                    (let*
                        ((from (save-restriction
                                (message-narrow-to-headers)
                                (message-fetch-field "from")))
                        (account
                        (cond
                        ((string-match "samarthkishor1@gmail.com" from) "gmail")
                        ((string-match "sk4gz@virginia.edu" from) "uva"))))
                    (setq message-sendmail-extra-arguments (list '"-a" account))))))

          ;; Use spellcheck when composing an email.
          (add-hook 'mu4e-compose-mode-hook 'flyspell-mode)

          ;; Define email contexts for my personal and school accounts.
          (setq mu4e-contexts
            `( ,(make-mu4e-context
                :name "gmail"
                :enter-func (lambda () (mu4e-message "Switch to the gmail context"))
                :match-func (lambda (msg)
                                (when msg
                                (mu4e-message-maildir-matches msg "^/gmail")))
                :leave-func (lambda () (mu4e-clear-caches))
                :vars '((user-mail-address     . "samarthkishor1@gmail.com")
                        (user-full-name        . "Samarth Kishor")
                        (mu4e-sent-folder      . "/gmail/sent")
                        (mu4e-drafts-folder    . "/gmail/drafts")
                        (mu4e-trash-folder     . "/gmail/trash")
                        (mu4e-refile-folder    . "/gmail/[Gmail].All Mail")))
                ,(make-mu4e-context
                :name "uva"
                :enter-func (lambda () (mu4e-message "Switch to the UVA context"))
                :match-func (lambda (msg)
                                (when msg
                                (mu4e-message-maildir-matches msg "^/uva")))
                :leave-func (lambda () (mu4e-clear-caches))
                :vars '((user-mail-address     . "sk4gz@virginia.edu")
                        (user-full-name        . "Samarth Kishor")
                        (mu4e-sent-folder      . "/uva/sent")
                        (mu4e-drafts-folder    . "/uva/drafts")
                        (mu4e-trash-folder     . "/uva/trash")
                        (mu4e-refile-folder    . "/uva/[Gmail].All Mail")))))

          ;; Gmail already sends sent mail to the Sent folder.
          (setq mu4e-sent-messages-behavior 'delete)

          ;; View and compose email in visual-line-mode for soft line wrapping.
          (add-hook 'mu4e-view-mode-hook #'visual-line-mode)
          (add-hook 'mu4e-compose-mode-hook #'visual-line-mode)

          ;; Handle html emails and preserve links.
          (setq mu4e-view-html-plaintext-ratio-heuristic most-positive-fixnum)

          (require 'mu4e-contrib)
          (setq mu4e-html2text-command 'mu4e-shr2text)
          (add-hook 'mu4e-view-mode-hook
                  (lambda()
                      ;; try to emulate some of the eww key-bindings
                      (local-set-key (kbd "<tab>") 'shr-next-link)
                      (local-set-key (kbd "<backtab>") 'shr-previous-link)))

          ;; Send mail with msmtp
          (setq message-send-mail-function 'message-send-mail-with-sendmail)
          (setq sendmail-program "${pkgs.msmtp}/bin/msmtp")
          (setq user-full-name "Samarth Kishor")
          ;; Tell msmtp to choose the SMTP server according to the "from" field in the outgoing email
          (setq message-sendmail-envelope-from 'header)
          (add-hook 'message-send-mail-hook 'choose-msmtp-account)
        '';
      };
    };
  };
}

function ide --wraps='tmuxinator start odoo' --description 'alias ide=tmuxinator start odoo'
  set -l session_name (string replace -a . _ -- (path basename $PWD))
  tmuxinator start odoo $argv
  # tmuxinator attaches automatically when not already inside tmux (blocking
  # until you detach); when nested (already inside a tmux client, e.g. called
  # from gow while sitting in another session) it just creates the session in
  # the background instead -- switch to it so it's not invisible
  if set --query TMUX
    tmux switch-client -t $session_name
  end
end

FROM noble

USER root

RUN \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  xvfb \
  x11vnc \
  fluxbox && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean && \
  rm -rf /var/cache/* /var/log/apt/* /tmp/*

ADD ./vnc_entrypoint.sh /home/odoo_user/vnc_entrypoint.sh

RUN mkdir -p /home/odoo_user/.config /home/odoo_user/.fluxbox && \
    echo ' \n\
       session.screen0.toolbar.visible:        false\n\
       session.screen0.fullMaximization:       true\n\
       session.screen0.maxDisableResize:       true\n\
       session.screen0.maxDisableMove: true\n\
       session.screen0.defaultDeco:    NONE\n\
    ' >> /home/odoo_user/.fluxbox/init && \
    chown -R odoo_user:odoo_user /home/odoo_user/.config /home/odoo_user/.fluxbox /home/odoo_user/vnc_entrypoint.sh && \
    chmod +x /home/odoo_user/vnc_entrypoint.sh

USER odoo_user

#TODO: Maybe this should be in the orignal dockerfile ?
WORKDIR /home/odoo_user

ENTRYPOINT ["/home/odoo_user/vnc_entrypoint.sh"]

# BASED ON https://github.com/jupemara/x11vnc-docker

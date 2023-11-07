inherit extrausers
EXTRA_USERS_PARAMS += "usermod -p \$(openssl passwd -6 tema2) root;"
IMAGE_INSTALL += "openssh"

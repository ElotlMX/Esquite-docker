#!/bin/bash
echo -n "corpus-admin:" > /home/elotl/users.pwd; echo -n "$CFG_CORPUS_ADMIN_PASS" | mkpasswd -s -m sha-512 >> /home/elotl/users.pwd
sudo service nginx restart
sed -i "s/INDEX:.*/INDEX: $CFG_INDEX/" /home/elotl/Esquite/env.yaml
sed -i "s/L1:.*/L1: $CFG_L1/" /home/elotl/Esquite/env.yaml
sed -i "s/L2:.*/L2: $CFG_L2/" /home/elotl/Esquite/env.yaml
sed -i "s,URL:.*,URL: $CFG_URL," /home/elotl/Esquite/env.yaml
sed -i "s/SECRET_KEY:.*/SECRET_KEY: $CFG_SECRET_KEY/" /home/elotl/Esquite/env.yaml
sed -i "s/ORG_NAME:.*/ORG_NAME: $CFG_ORG_NAME/" /home/elotl/Esquite/env.yaml
sed -i "s/GOOGLE_ANALYTICS:.*/GOOGLE_ANALYTICS: $CFG_GOOGLE_ANALYTICS/" /home/elotl/Esquite/env.yaml
sed -i "s/NAME:.*/NAME: $CFG_NAME/" /home/elotl/Esquite/env.yaml
sed -i "s,blog:.*,blog: $CFG_BLOG," /home/elotl/Esquite/env.yaml
sed -i "s/email:.*/email: $CFG_EMAIL/" /home/elotl/Esquite/env.yaml
sed -i "s,facebook:.*,facebook: $CFG_FACEBOOK," /home/elotl/Esquite/env.yaml
sed -i "s,site:.*,site: $CFG_SITE," /home/elotl/Esquite/env.yaml
sed -i "s,twitter:.*,twitter: $CFG_TWITTER," /home/elotl/Esquite/env.yaml
sed -i "s/META_DESC:.*/META_DESC: $CFG_META_DESC/" /home/elotl/Esquite/env.yaml
cd /home/elotl/Esquite
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:3000

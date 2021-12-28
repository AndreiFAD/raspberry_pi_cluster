#!/bin/bash
# ------------------------------------------------------------------
# sudo nano install.sh
# install:
#	nodejs
#	python libraries
#	hadoop and spark library
#	hive library
#	jupyter
# kernels:
#	Scala kernel
#	R kernel
#	Julia kernel
#	SQL kernel
#	Bash kernel
#	Python kernel
# ------------------------------------------------------------------
hostAddress="master"

sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get update
sudo apt-get -y install python python3-dev python3-pip htpdate net-tools  build-essential libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libffi-dev libxpm-dev libxext-dev libbz2-dev libncurses5-dev libjpeg8 libjpeg62-dev libfreetype6 libfreetype6-dev curl dirmngr apt-transport-https lsb-release ca-certificates libcurl4-gnutls-dev libxml2-dev gcc g++ make

# openjdk-8-jdk
sudo apt install software-properties-common
sudo add-apt-repository ppa:linuxuprising/java -y
sudo apt-get -y install openjdk-8-jdk

# nodejs
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash
sudo apt update
sudo apt -y install nodejs

# python libs
sudo python3 -m pip install --upgrade --force-reinstall pip
sudo pip3 install -U pip
sudo pip3 install --upgrade pip
sudo pip3 install numpy pandas ipython pillow jupyter jupyterlab plotly ipywidgets jupyter-dash jupyterlab-dash bokeh dash findspark notebook
sudo apt -y install python3-matplotlib python3-scipy
sudo apt -y install ipython3
sudo apt -y install python3-sklearn python3-sklearn-lib python3-sklearn-doc
sudo apt -y install python-numpy python-scipy python-matplotlib ipython python-pandas python-sympy python-nose


# hadoop and spark
cd
wget https://archive.apache.org/dist/hadoop/core/hadoop-3.2.1/hadoop-3.2.1.tar.gz
wget https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz
sudo tar -xvf hadoop-3.2.1.tar.gz -C /opt/
sudo tar -xvf spark-2.4.5-bin-hadoop2.7.tgz  -C /opt/
cd /opt/
sudo mv hadoop-3.2.1 hadoop
sudo mv spark-2.4.5-bin-hadoop2.7 spark

# hive
cd
wget  https://downloads.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
sudo tar -xvf apache-hive-3.1.2-bin.tar.gz
sudo mv apache-hive-3.1.2-bin hive
sudo mv hive /opt/

cd
sudo mkdir  /opt/hadoop_tmp
sudo mkdir -p /opt/hadoop_tmp/hdfs/datanode
sudo mkdir -p /opt/hadoop_tmp/hdfs/namenode

sudo chown -R pi:pi /opt/spark
sudo chown -R pi:pi /opt/hive
sudo chown -R pi:pi /opt/hadoop
sudo chown -R pi:pi /opt/hadoop_tmp
sudo chown -R pi:pi /opt/

# extra conf to jupyter
sudo jupyter notebook -y --generate-config
cd $home
sudo mkdir -p notebooks

#  spylon kernel scala
sudo pip3 install spylon-kernel
sudo python3 -m spylon_kernel install --user

sudo sed -i '1d' /home/pi/.local/share/jupyter/kernels/spylon-kernel/kernel.json
sudo echo  '{"argv": ["/usr/bin/python3", "-m", "spylon_kernel", "-f", "{connection_file}"], "display_name": "Scala", "env": {"PYTHONUNBUFFERED": "1", "SPARK_SUBMIT_OPTS": "-Dscala.usejavacp=true"}, "language": "scala", "name": "spylon-kernel"}' >> /home/pi/.local/share/jupyter/kernels/spylon-kernel/kernel.json


#  R kernel
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran40/'
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu trusty/'
sudo apt update
sudo apt-get install -y gfortran libreadline6-dev libx11-dev libxt-dev \
                               libpng-dev libjpeg-dev libcairo2-dev xvfb \
                               libbz2-dev libzstd-dev liblzma-dev \
                               libcurl4-openssl-dev \
                               texinfo texlive texlive-fonts-extra \
                               screen wget libpcre2-dev build-essential libatomic1 gfortran perl wget m4 \
				cmake pkg-config libopenblas-base libopenblas-dev libatlas3-base \
				 liblapack-dev libmpfr-dev libgmp3-dev gfortran

sudo apt-get install -y build-essential
sudo apt-get install -y fort77
sudo apt-get install -y xorg-dev
sudo apt-get install -y liblzma-dev  libblas-dev gfortran
sudo apt-get install -y gcc-multilib
sudo apt-get install -y gobjc++
sudo apt-get install -y aptitude
sudo aptitude install -y libreadline-dev

sudo sed -i "s/# deb-src/deb-src/g" /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y build-dep r-base-dev

cd /usr/local/src
sudo wget -c https://cran.r-project.org/src/base/R-4/R-4.1.0.tar.gz
sudo tar -xf R-4.1.0.tar.gz
cd R-4.1.0
sudo ./configure
sudo make -j9
sudo make install
cd ..
sudo rm -rf R-3.6.3*
cd

sudo Rscript -e 'install.packages("IRkernel", repos="https://cloud.r-project.org")'
sudo Rscript -e 'IRkernel::installspec(displayname = "R 4.1.0")'

sudo echo > /home/pi/.local/share/jupyter/kernels/ir/kernel.json
sudo echo  '{ "argv": ["/usr/local/lib/R/bin/R", "--slave", "-e", "IRkernel::main()", "--args", "{connection_file}"], "display_name": "R 4.1.0", "language": "R"}' >> /home/pi/.local/share/jupyter/kernels/ir/kernel.json

sudo Rscript -e 'install.packages("dplyr", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("ggplot2", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("tidyr", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("shiny", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("caret", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("E1071", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("plotly", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("tidyquant", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("repr", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("evaluate", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("crayon", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("pbdZMQ", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("devtools", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("uuid", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("digest", repo = "https://lib.ugent.be/CRAN/")'
sudo Rscript -e 'install.packages("stringi", repo = "https://lib.ugent.be/CRAN/")'

#  julia kernel
# sudo apt install julia -y
cd /usr/local/src
sudo git clone git://github.com/JuliaLang/julia.git
cd julia
sudo git checkout v1.5.3
sudo make install
sudo ln -s /usr/local/src/julia/julia /usr/bin/julia
sudo julia -e 'using Pkg; Pkg.add("IJulia");'
sudo julia -e 'using IJulia;'

# SQLite kernel
sudo apt-get install -y sqlite3
sudo git clone https://github.com/brownan/sqlite3-kernel.git
cd sqlite3-kernel
sudo python3 setup.py install
sudo python3 -m sqlite3_kernel.install --user
cd ..
sudo rm -rf sqlite3-kernel/

# Install TeX to convert Jupyter notebooks to other formats etc PDF.
sudo apt install -y texlive-xetex
sudo apt install -y latexmk

# bash kernel
sudo pip3 install bash_kernel
sudo python3 -m bash_kernel.install --user

sudo jupyter lab clean
sudo jupyter nbextension enable --py widgetsnbextension
sudo jupyter labextension install jupyterlab-dash --no-build --minimize=False
sudo jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build --minimize=False
sudo jupyter labextension install bqplot --no-build --minimize=False
sudo jupyter labextension install jupyter-leaflet --no-build --minimize=False
sudo jupyter lab build  --dev-build=False --minimize=False

sudo htpdate -a -l www.pool.ntp.org

sudo chown -R pi:pi /usr/src/
sudo chown -R pi:pi /usr/share/
sudo chown -R pi:pi /usr/local/
sudo chown -R pi:pi /home/pi/


sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-armhf/jre/bin/java

sudo touch /opt/spark/conf/master
sudo sh -c "echo 'master' >> /opt/spark/conf/master"

#!/bin/bash
echo '# HADOOP - SPARK - HIVE variables' >> ~/.bashrc
echo 'export PYTHONHASHSEED=123' >>  ~/.bashrc
echo 'export PYSPARK_PYTHON=/usr/bin/python3' >> ~/.bashrc
echo 'export PYSPARK_DRIVER_PYTHON=ipython3' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-armhf' >> ~/.bashrc
echo 'export HADOOP_HOME=/opt/hadoop' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
echo 'export SPARK_HOME=/opt/spark' >> ~/.bashrc
echo 'export PATH=$PATH:$SPARK_HOME/bin' >> ~/.bashrc
echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"' >> ~/.bashrc
echo 'export HIVE_HOME=/opt/hive' >> ~/.bashrc
echo 'export PATH=$PATH:/opt/hive/bin' >> ~/.bashrc
echo 'export HIVE_CONF_DIR=/opt/hive/conf' >> ~/.bashrc
echo 'export PATH=$PATH:$HIVE_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
. ~/.bashrc

host=$(hostname)
if [ "$host" = "$hostAddress" ]; then


    printf '%s\n' "on the master host"
    sudo apt update
    sudo apt install -y postgresql postgresql-contrib
    psql -V

    sudo sed -i -e 's/^/#/' /etc/postgresql/10/main/pg_hba.conf
    {
    echo 'local   all             postgres                                trust'
    echo 'local   all             all                                     md5'
    echo 'host    all             all             127.0.0.1/32            md5'
    echo 'host    all             all             ::1/128                 md5'
    echo 'local   replication     all                                     peer'
    echo 'host    replication     all             127.0.0.1/32            md5'
    echo 'host    replication     all             ::1/128                 md5'
    echo 'host    all             all             0.0.0.0/0                 trust'
    } >> /etc/postgresql/10/main/pg_hba.conf

    sudo sh -c "echo \"listen_addresses = '*'\" >> /etc/postgresql/10/main/postgresql.conf"
    sudo service postgresql restart
    sudo echo "CREATE USER hive WITH PASSWORD 'hive';" | psql -U postgres 
    sudo echo "CREATE DATABASE metastore;" | psql -U postgres
    sudo echo "GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;" | psql -U postgres
    sudo rm /opt/hive/lib/guava-19.0.jar
    sudo cp /opt/hadoop/share/hadoop/common/lib/guava-27.0-jre.jar /opt/hive/lib/
    cp /opt/hive/conf/hive-env.sh.template  /opt/hive/conf/hive-env.sh
    cd /opt/hive/lib/
    sudo wget https://jdbc.postgresql.org/download/postgresql-42.2.24.jar

    sudo mv /opt/hive/conf/hivemetastore-site.xml /opt/hive/conf/hivemetastore-site.xmlbak
    sudo mv /opt/hive/conf/hiveserver2-site.xml /opt/hive/conf/hiveserver2-site.xmlbak
    sudo mv /opt/hive/conf/hive-env.sh /opt/hive/conf/hive-env.shbak

    cd
    cd /opt/hive/conf/
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/hivemetastore-site.xml
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/hive-env.sh
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/hiveserver2-site.xml

    cd
    cd /opt/hive/bin
    ./schematool -dbType postgres -initSchema

    sudo touch /opt/spark/conf/slaves
    sudo sh -c "echo 'worker1' >> /opt/spark/conf/slaves"
    sudo sh -c "echo 'worker2' >> /opt/spark/conf/slaves"
    sudo sh -c "echo 'worker3' >> /opt/spark/conf/slaves"

    sudo touch /opt/hadoop/etc/hadoop/workers
    sudo sh -c "echo 'worker1' >> /opt/hadoop/etc/hadoop/workers"
    sudo sh -c "echo 'worker2' >> /opt/hadoop/etc/hadoop/workers"
    sudo sh -c "echo 'worker3' >> /opt/hadoop/etc/hadoop/workers"
    
    
    sudo mv /opt/hadoop/etc/hadoop/capacity-scheduler.xml /opt/hadoop/etc/hadoop/capacity-scheduler.xmlbak
    sudo mv /opt/hadoop/etc/hadoop/core-site.xml /opt/hadoop/etc/hadoop/core-site.xmlbak
    sudo mv /opt/hadoop/etc/hadoop/hadoop-env.sh /opt/hadoop/etc/hadoop/hadoop-env.shbak
    sudo mv /opt/hadoop/etc/hadoop/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xmlbak
    sudo mv /opt/hadoop/etc/hadoop/mapred-site.xml /opt/hadoop/etc/hadoop/mapred-site.xmlbak
    sudo mv /opt/hadoop/etc/hadoop/yarn-site.xml /opt/hadoop/etc/hadoop/yarn-site.xmlbak

    cd
    cd /opt/hadoop/etc/
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/capacity-scheduler.xml
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/core-site.xml
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/hdfs-site.xml
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/mapred-site.xml
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/yarn-site.xml
    
    cd
    cd /opt/spark/conf/
    sudo wget https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/spark-defaults.conf

    sudo sh -c "echo 'export HADOOP_HOME=/opt/hadoop' >> /opt/spark/conf/spark-env.sh"
    sudo sh -c "echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> /opt/spark/conf/spark-env.sh"

    sudo sh -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-armhf' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"

else
    printf '%s\n' "uh-oh, not on the master host"
fi

sudo htpdate -a -l www.pool.ntp.org
echo "R:"
R --version
echo "Julia:"
julia -v
echo "java:"
java -version
echo "python:"
python -V
echo "python3:"
python3 -V
echo "NodeJS:"
node -v
echo "npm:"
npm -v
echo
echo "jupyter installed kernels and extensions"
sudo jupyter kernelspec list
sudo jupyter labextension list

host=$(hostname)
if [ "$host" = "$hostAddress" ]; then

    hdfs namenode -format -force

    start-dfs.sh
    start-yarn.sh
    cd /opt/spark 
    ./sbin/start-all.sh

    hdfs dfsadmin -safemode leave

    hdfs dfs -mkdir -p /user/hive/warehouse
    hdfs dfs -chmod g+w /user/hive/warehouse
    hdfs dfs -mkdir -p /tmp
    hdfs dfs -chmod g+w /tmp
    hdfs dfs -chmod -R 755 /tmp

    echo "hive metastore start"
    /opt/hive/bin/hive --service metastore > /dev/null 2>&1 &
    echo "hive hiveserver2 start"
    /opt/hive/bin/hive --service hiveserver2 > /dev/null 2>&1 &


    echo "Jupiter config file - sudo nano /home/pi/.jupyter/jupyter_notebook_config.py"
    echo "Jupiter notebook password - sudo jupyter notebook password"
    echo "sudo nano /home/pi/.local/share/jupyter/kernels/ir/kernel.json"
    echo "You can start with this command - sudo jupyter notebook --allow-root"

else
    printf '%s\n' "uh-oh, not on the master host"
fi


#!/bin/bash

# LOG OUTPUT TO A FILE
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/root/.hadoop_automate/log.out 2>&1

if [[ ! -f "/root/.hadoop_automate/init.cfg" ]]
then
  # Install unzip
  apt install unzip -y
  # Install Java 8
  apt install openjdk-8-jdk-headless -y
  apt install openjdk-8-jre-headless -y
  # Install Ant
  wget -q --show-progress --https-only --timestamping http://apache.mirrors.tds.net//ant/binaries/apache-ant-1.10.6-bin.zip
  unzip $PWD/apache-ant-1.10.6-bin.zip
  rm -rf $PWD/apache-ant-1.10.6-bin.zip
  mv $PWD/apache-ant-1.10.6 /usr/share/
  # Install Maven
  wget -q --show-progress --https-only --timestamping http://mirror.metrocast.net/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.zip
  unzip apache-maven-3.6.1-bin.zip
  rm -rf $PWD/apache-maven-3.6.1-bin.zip
  mv $PWD/apache-maven-3.6.1 /usr/share
  # Download Hadoop Binary
  wget -q --show-progress --https-only --timestamping http://apache-mirror.8birdsvideo.com/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
  # Extract
  tar -xvf $PWD/hadoop-3.2.1.tar.gz
  # Rename
  mv $PWD/hadoop-3.2.1 $PWD/hadoop
  # Move into /usr/local
  mv $PWD/hadoop/ /usr/local/
  # remove hadoop tar
  rm -rf $PWD/hadoop-3.2.1.tar.gz
  # add /usr/local/hadoop to /etc/environment
  # Set JAVA_HOME Environment Variable:
  cat <<EOF > /etc/environment
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/share/apache-ant-1.10.6/bin:/usr/share/apache-maven-3.6.1/bin:/usr/local/hadoop/bin:/usr/local/hadoop/sbin"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export _JAVA_OPTIONS="-Djava.net.preferIPv4Stack=true"
export ANT_HOME=/usr/share/apache-ant-1.10.6
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_COMMON_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
export HADOOP_HDFS_HOME=/usr/local/hadoop
export HADOOP_MAPRED_HOME=/usr/local/hadoop
export HADOOP_YARN_HOME=/usr/local/hadoop
EOF
  source /etc/environment
  # Create Directories
  mkdir -p /usr/local/hadoop/data/nameNode
  mkdir -p /usr/local/hadoop/data/dataNode
  # Set Permissions
  chown hadoop:root -R /usr/local/hadoop
  chmod g+rwx -R /usr/local/hadoop
  # Configure Hadoop Master
  cat <<EOF > /usr/local/hadoop/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>fs.default.name</name>
    <value>hdfs://hadoop000.management.skyfall.io:9000</value>
  </property>
</configuration>
EOF

  cat <<EOF > /usr/local/hadoop/etc/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:///usr/local/hadoop/data/nameNode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///usr/local/hadoop/data/dataNode</value>
  </property>
  <property>
    <name>dfs.replication</name>
    <value>3</value>
  </property>
</configuration>
EOF

  cat <<EOF > /usr/local/hadoop/etc/hadoop/masters
hadoop000.management.skyfall.io
EOF

  cat <<EOF > /usr/local/hadoop/etc/hadoop/workers
hadoop001.management.skyfall.io
hadoop002.management.skyfall.io
hadoop003.management.skyfall.io
EOF

  cat <<EOF > /usr/local/hadoop/etc/hadoop/yarn-site.xml
<?xml version="1.0"?>
  <!--
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License. See accompanying LICENSE file.
  -->
<configuration>
 <!-- Site specific YARN configuration properties -->
 <property>
  <name>yarn.nodemanager.aux-services</name>
  <value>mapreduce_shuffle</value>
 </property>
 <property>
  <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
  <value>org.apache.hadoop.mapred.ShuffleHandler</value>
 </property>
 <property>
  <name>yarn.resourcemanager.hostname</name>
  <value>hadoop000.management.skyfall.io</value>
 </property>
</configuration>
EOF

  cat <<EOF > /usr/local/hadoop/etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
 <property>
   <name>mapreduce.jobtracker.address</name>
   <value>hadoopmaster000.management.skyfall.io:54311</value>
 </property>
 <property>
  <name>mapreduce.framework.name</name>
  <value>yarn</value>
 </property>
 <property>
  <name>yarn.app.mapreduce.am.env</name>
  <value>HADOOP_MAPRED_HOME=file:///usr/local/hadoop</value>
 </property>
 <property>
  <name>mapreduce.map.env</name>
  <value>HADOOP_MAPRED_HOME=file:///usr/local/hadoop</value>
 </property>
 <property>
  <name>mapreduce.reduce.env</name>
  <value>HADOOP_MAPRED_HOME=file:///usr/local/hadoop</value>
 </property>
</configuration>
EOF
  # Output
  echo "run this: yarn jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar pi 16 1000"
  # Idempotentcy
  touch /root/.hadoop_automate/init.cfg
fi

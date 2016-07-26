############################################################################
# (C) Copyright IBM Corporation 2015.                                      #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#      http://www.apache.org/licenses/LICENSE-2.0                          #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
#                                                                          #
############################################################################

FROM ibmcom/ibm-http-server:8.5.5.9

COPY responsefile.txt /opt/IBM/WebSphere/Toolbox/WCT/

RUN /opt/IBM/WebSphere/Toolbox/WCT/wctcmd.sh -tool pct -defLocPathname \
    /opt/IBM/WebSphere/Plugins -defLocName loc1 -createDefinition \
    -response /opt/IBM/WebSphere/Toolbox/WCT/responsefile.txt

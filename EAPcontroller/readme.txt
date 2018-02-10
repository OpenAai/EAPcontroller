EAP Controller v2.5.3 for Linux (X64)

New Features and Enhancement:
1. Having added Local User, Facebook and SMS authentication methods in Portal.
2. Supporting multiple portal rules to be configured at the same time.
3. Having added rate limit and traffic limit function in Voucher authentication.
4. Providing more flexible customization of Portal pages, able to customize advertisements on the Portal login page;
5. Supporting special characters such as ¡®& ... *! + =¡¯in Radius password.

6. Supporting DNS configuration under static IP address.

System and Environment Requirements:
1. 64-bit Linux operating system, including Ubuntu 14.04/16.04/17.04, CentOS 6.x/7.x and Fedora 20 or above.
2. Require JRE 1.7 (or above) Java environment.

Installation Steps:
1. Make sure your PC is running in root mode. You can use this command to enter root mode: su - root

2. Create a folder named as eap.

3. Extract this RAR file using the command: tar zxvf EAP_Controller_v2.4.8_Linux_x64.tar.gz -C eap

4. Install EAP Controller using the command: sudo ./install.sh

5. Start the EAP Controller service using the command: tpeap start. Launch a web browser and visit http://127.0.0.1:8088 to enter the management interface of EAP Controller.

   You can also use the following commands to stop the service or view the service status:
   To stop the service: tpeap stop
   To view the service status: tpeap status

6. Follow the quick setup wizard to complete the basic settings. 
   For more instructions, please refer to the User Guide of EAP Controller.


Tips and Notes:
1. To uninstall EAP Controller, go to the insatllation path: /opt/tplink/EAPController, and run the command: sudo ./uninstall.sh.

2. During the uninstallation, you can choose whether to backup the database. The backup folder is /opt/tplink/EAPController/eap_db_backup. 

3. During installation, you will be asked whether to restore the database if there is any backup database in the folder /opt/tplink/EAPController/eap_db_backup.

4. If the EAP Controller cannot detect EAP devices, it is possibly because the firewall intercepts the service. 
   Please make sure that the ports 8088, 8043, 27001, 27002, 29810, 29811, 29812 and 29813 are available.

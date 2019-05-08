# Website Deployer

## Description
Site deploy is a script to prepare and install a fresh and tuned Web Server stack based on Nginx / PHP FPM / Redis. After that, relunch the script and deploy your mutualised ans isolated websites.

## Functionalities
 - Prepare, update and install all you need to host Websites
 - Deploy tuned configuration for Nginx, PHP-FPM, Opcache and Redis.
 - Ready to use to deploy Wordpress and Static website’s optimized Vhost
 - Good configuration for caching with (in option) Fast-CGI Cache, Opcache or Cloudflare. 
 - Full secured configuration based on Let’s Encrypt with HTTP or DNS challenge (included Cloudflare DNS challenge).

## Installation
To install site-deploy script, follow these steps :
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/bilyboy785/site-deployer/master/tools/install.sh)"
```
  
## DNS Challenge manager
### Cloudflare
You need to have a Cloudflare Account and get your Global API Key from your profile :
![](https://i.imgur.com/02gzqvR.png)

When site-deploy ask you Email and API, put it, they'll be store on the server.

### OVH
To deal with OVH Certbot plugin, go to the [Token API OVH's Page](https://api.ovh.com/createToken/) and generate your Key with the following options :
 * **GET** /domain/zone/*
 * **PUT** /domain/zone/*
 * **POST** /domain/zone/*
 * **DELETE** /domain/zone/*

![](https://i.imgur.com/WfE0WcV.png)


## Packages version
 - **Nginx** : 1.14.0
 - **PHP** : 7.0/7.1/7.2/7.3
 - **Redis** : 4.0.9
 - **Certbot** : 0.23.0
 - **Python** : 3.6.7
 - **Wordpress** : latest

## Tested on
 - [X] Ubuntu 14/16/18
 - [X] Debian 7/8/9

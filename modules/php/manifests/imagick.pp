# module to install and configure php module ImageMagick
# It is a native php extension to create and modify images using the
# ImageMagick API
class php::imagick() {
  package { 'php5-imagick':
    ensure => installed
  }
}

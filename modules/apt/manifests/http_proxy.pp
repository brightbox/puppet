# proxy_url should be like http://1.2.3.4:8080
class apt::http_proxy($url) {
  file { '/etc/apt/apt.conf.d/http_proxy':
    content => "Acquire::http::Proxy \"${url}\";",
    notify => Exec['apt-update']
  }
}

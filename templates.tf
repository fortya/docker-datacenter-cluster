data "template_file" "docker" {
  template = "${file("${path.module}/templates/docker.sh.tpl")}"

  vars {
    DOCKER_EE_URL     = "${var.docker_ee_url}"
    DOCKER_EE_VERSION = "${var.docker_ee_version}"
  }
}


data "template_file" "node-master" {
  template = "${file("${path.module}/templates/nodes/manager.master.sh.tpl")}"

  vars {
    UCP_PUBLIC_ENDPOINT = "${var.ucp_endpoint}"
    DTR_PUBLIC_ENDPOINT = "${var.dtr_endpoint}"
    DTR_HTTP_PORT       = "${var.dtr_http_port}"
    DTR_HTTPS_PORT      = "${var.dtr_https_port}"
    ELB_MASTER_NODES    = "${module.node-master-elb.this_elb_dns_name}"
    ELB_MANAGER_NODES   = "${module.node-manager-elb.this_elb_dns_name}"
    DOCKER_INSTALL      = "${data.template_file.docker.rendered}"
    DOCKER_UCP_VERSION  = "${var.docker_ucp_version}"
    DOCKER_UCP_USERNAME = "${var.ucp_username}"
    DOCKER_UCP_PASSWORD = "${var.ucp_password}"
  }
}

data "template_file" "node-manager" {
  template = "${file("${path.module}/templates/nodes/manager.replica.sh.tpl")}"

  vars {
    UCP_TOKEN           = "${var.ucp_token_manager}"
    DOCKER_INSTALL      = "${data.template_file.docker.rendered}"
    DOCKER_UCP_VERSION  = "${var.docker_ucp_version}"
    DOCKER_UCP_USERNAME = "${var.ucp_username}"
    DOCKER_UCP_PASSWORD = "${var.ucp_password}"
    UCP_PUBLIC_ENDPOINT = "${var.ucp_endpoint}"
    ELB_MASTER_NODES    = "${module.node-master-elb.this_elb_dns_name}"
    ELB_MANAGER_NODES   = "${module.node-manager-elb.this_elb_dns_name}"
    DTR_HTTP_PORT       = "${var.dtr_http_port}"
    DTR_HTTPS_PORT      = "${var.dtr_https_port}"
    DTR_REPLICA_ID      = "${var.dtr_replica_id}"
    DTR_PUBLIC_ENDPOINT = "${var.dtr_endpoint}"
  }
}

data "template_file" "node-worker" {
  template = "${file("${path.module}/templates/nodes/worker.sh.tpl")}"

  vars {
    UCP_PUBLIC_ENDPOINT = "${var.ucp_endpoint}"
    DOCKER_INSTALL      = "${data.template_file.docker.rendered}"
    UCP_TOKEN           = "${var.ucp_token_worker}"
  }
}

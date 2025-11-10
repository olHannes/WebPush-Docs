CREATE TABLE smartmonitoring.datajobs (
	id bigserial NOT NULL,
	"name" varchar NULL,
	"desc" varchar NULL,
	"action" varchar NULL,
	active bool NULL,
	"start" timestamp NULL,
	stop timestamp NULL,
	repeatsecs int4 NULL,
	CONSTRAINT datajobs_pk PRIMARY KEY (id)
);

CREATE TABLE smartmonitoring.datajobs_params (
	id bigserial NOT NULL,
	"key" varchar NOT NULL,
	value varchar NOT NULL,
	datajob_id int8 NOT NULL,
	"type" varchar NOT NULL,
	CONSTRAINT datajobs_params_pk PRIMARY KEY (id)
);


-- smartmonitoring.datajobs_params foreign keys

ALTER TABLE smartmonitoring.datajobs_params ADD CONSTRAINT datajobs_params_datajobs_fk FOREIGN KEY (datajob_id) REFERENCES smartmonitoring.datajobs(id) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE smartmonitoring.datajobs_log (
	id bigserial NOT NULL,
	datajob_id int8 NOT NULL,
	"result" text NULL,
	ts timestamp DEFAULT now() NOT NULL,
	iserror bool NULL,
	CONSTRAINT datajobs_log_pk PRIMARY KEY (id),
	CONSTRAINT datajobs_log_unique UNIQUE (id)
);


-- smartmonitoring.datajobs_log foreign keys

ALTER TABLE smartmonitoring.datajobs_log ADD CONSTRAINT datajobs_log_datajobs_fk FOREIGN KEY (datajob_id) REFERENCES smartmonitoring.datajobs(id) ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE TABLE smartmonitoring.datajobs_chain (
	id bigserial NOT NULL,
	pre_job_id int8 NOT NULL,
	post_job_id int8 NOT NULL,
	checkkey varchar NULL,
	checkvalue varchar NULL,
	checkchanged varchar NULL,
	CONSTRAINT datajobs_chain_pk PRIMARY KEY (id)
);


-- smartmonitoring.datajobs_chain foreign keys

ALTER TABLE smartmonitoring.datajobs_chain ADD CONSTRAINT datajobs_chain_datajobs_fk_post_job FOREIGN KEY (post_job_id) REFERENCES smartmonitoring.datajobs(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE smartmonitoring.datajobs_chain ADD CONSTRAINT datajobs_chain_datajobs_fk_pre_job FOREIGN KEY (pre_job_id) REFERENCES smartmonitoring.datajobs(id) ON DELETE CASCADE ON UPDATE CASCADE;


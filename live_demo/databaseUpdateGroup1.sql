-- CREATES ------------------------------------------------------------------------------------------------------------------------------

-- smartmonitoring.label_image definition

-- Drop table

-- DROP TABLE smartmonitoring.label_image;

CREATE TABLE smartmonitoring.label_image (
	id bigserial NOT NULL,
	image_path varchar NOT NULL,
	label_id int8 NOT NULL,
	CONSTRAINT label_image_pk PRIMARY KEY (id)
);

-- smartmonitoring.label_image foreign keys

ALTER TABLE smartmonitoring.label_image ADD CONSTRAINT label_image_label_labels_fk FOREIGN KEY (label_id) REFERENCES smartmonitoring.label_labels(id);

-----------------------------------------------------------------------------------------------------------------------------------------

-- smartmonitoring.means_of_travel definition

-- Drop table

-- DROP TABLE smartmonitoring.means_of_travel;

CREATE TABLE smartmonitoring.means_of_travel (
	id bigserial NOT NULL,
	"name" varchar NOT NULL,
	description varchar NULL,
	image_file varchar NULL,
	CONSTRAINT meansoftravel_pk PRIMARY KEY (id)
);

-----------------------------------------------------------------------------------------------------------------------------------------

-- smartmonitoring.means_of_travel_join_process definition

-- Drop table

-- DROP TABLE smartmonitoring.means_of_travel_join_process;

CREATE TABLE smartmonitoring.means_of_travel_join_process (
	id bigserial NOT NULL,
	means_of_travel_id int8 NOT NULL,
	measurement_process_id varchar NOT NULL,
	data_collection varchar NOT NULL,
	CONSTRAINT meansoftravel_process_pk PRIMARY KEY (id)
);

-- smartmonitoring.means_of_travel_join_process foreign keys

ALTER TABLE smartmonitoring.means_of_travel_join_process ADD CONSTRAINT meansoftravel_process_meansoftravel_fk FOREIGN KEY (means_of_travel_id) REFERENCES smartmonitoring.means_of_travel(id);


-- INSERTS ------------------------------------------------------------------------------------------------------------------------------

INSERT INTO smartmonitoring.label_labels (id,"name",color,isavailforobjects,isavailfordatasets,isavailformediasets) VALUES
	 (999,'fog/Clouds',NULL,false,true,false),
	 (1000,'crowd',NULL,false,true,false),
	 (1001,'heavyTraffic',NULL,false,true,false),
	 (1002,'constructionSite',NULL,false,true,false),
	 (1003,'fire/Smoke',NULL,false,true,false),
	 (1004,'rain',NULL,false,true,false),
	 (1005,'snow',NULL,false,true,false);

INSERT INTO smartmonitoring.label_image (image_path,label_id) VALUES
	 ('cloudy.png',999),
	 ('crowd.png',1000),
	 ('traffic.png',1001),
	 ('construction.png',1002),
	 ('fire.png',1003),
	 ('rain.png',1004),
	 ('snow.png',1005);
	 
INSERT INTO smartmonitoring.means_of_travel ("name",description,image_file) VALUES
	 ('walking','','man.png'),
	 ('bicycle','','bicycle.png'),
	 ('scooter/eBike','','scooter.png'),
	 ('motorcycle','','motorcycle.png'),
	 ('car','','car.png');
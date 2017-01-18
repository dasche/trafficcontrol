package TrafficOpsRoutes;
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
#

sub new {
	my $self  = {};
	my $class = shift;
	return ( bless( $self, $class ) );
}

sub define {
	my $self = shift;
	my $r    = shift;

	$self->ui_routes($r);

	my $namespace = "API";

	# 1.0 Routes
	$self->api_1_0_routes( $r, "UI" );

	# $version Routes
	my $version = "1.1";
	$self->api_routes( $r, $version, $namespace );

	# 1.2 Routes
	$version = "1.2";
	$self->api_routes( $r, $version, $namespace );

	# Traffic Stats Extension
	$self->traffic_stats_routes( $r, $version );

	$self->catch_all( $r, $namespace );
}

sub ui_routes {
	my $self      = shift;
	my $r         = shift;
	my $namespace = "UI";

	# This route needs to be at the top to kick in first.
	$r->get('/')->over( authenticated => 1 )->to( 'RascalStatus#health', namespace => $namespace );

	# ------------------------------------------------------------------------
	# NOTE: Routes should be grouped by their controller
	# ------------------------------------------------------------------------
	# -- About
	$r->get('/help/about')->over( authenticated => 1 )->to( 'Help#about', namespace => $namespace );
	$r->get('/help/releasenotes')->over( authenticated => 1 )->to( 'Help#releasenotes', namespace => $namespace );

	# -- Anomaly
	$r->get('/anomaly/:host_name')->to( 'Anomaly#start', namespace => $namespace );

	# -- BlueImpLoader
	$r->get('/blueimp_uploader')->over( authenticated => 1 )->to( 'blueimp_uploader#blueimp', namespace => $namespace );

	# -- Cachegroup
	# deprecated - see: /api/$version/location/:parameter_id/parameter
	# $r->get('/availablelocation/:paramid')->over( authenticated => 1 )->to( 'Cachegroup#availablelocation', namespace => $namespace );
	$r->get('/misc')->over( authenticated => 1 )->to( 'Cachegroup#index', namespace => $namespace );
	$r->get('/cachegroups')->over( authenticated => 1 )->to( 'Cachegroup#index', namespace => $namespace );
	$r->get('/cachegroup/add')->over( authenticated => 1 )->to( 'Cachegroup#add', namespace => $namespace );
	$r->post('/cachegroup/create')->over( authenticated => 1 )->to( 'Cachegroup#create', namespace => $namespace );
	$r->get('/cachegroup/:id/delete')->over( authenticated => 1 )->to( 'Cachegroup#delete', namespace => $namespace );

	# mode is either 'edit' or 'view'.
	$r->route('/cachegroup/:mode/:id')->via('GET')->over( authenticated => 1 )->to( 'Cachegroup#view', namespace => $namespace );
	$r->post('/cachegroup/:id/update')->over( authenticated => 1 )->to( 'Cachegroup#update', namespace => $namespace );

	# -- Cdn
	$r->post('/login')->to( 'Cdn#login',         namespace => $namespace );
	$r->get('/logout')->to( 'Cdn#logoutclicked', namespace => $namespace );
	$r->get('/loginpage')->to( 'Cdn#loginpage', namespace => $namespace );
	$r->get('/')->to( 'Cdn#loginpage', namespace => $namespace );

	# Cdn - Special JSON format for datatables widget
	$r->get('/aadata/:table')->over( authenticated => 1 )->to( 'Cdn#aadata', namespace => $namespace );
	$r->get('/aadata/:table/:filter/#value')->over( authenticated => 1 )->to( 'Cdn#aadata', namespace => $namespace );

	# -- Changelog
	$r->get('/log')->over( authenticated => 1 )->to( 'ChangeLog#changelog', namespace => $namespace );
	$r->post('/create/log')->over( authenticated => 1 )->to( 'ChangeLog#createlog',   namespace => $namespace );
	$r->get('/newlogcount')->over( authenticated => 1 )->to( 'ChangeLog#newlogcount', namespace => $namespace );

	# -- Configuredrac - Configure Dell DRAC settings (RAID, BIOS, etc)
	$r->post('/configuredrac')->over( authenticated => 1 )->to( 'Dell#configuredrac', namespace => $namespace );

	# -- Configfiles
	$r->route('/genfiles/:mode/:id/#filename')->via('GET')->over( authenticated => 1 )->to( 'ConfigFiles#genfiles', namespace => $namespace );

	# -- Asn
	$r->get('/asns')->over( authenticated => 1 )->to( 'Asn#index', namespace => $namespace );
	$r->get('/asns/add')->over( authenticated => 1 )->to( 'Asn#add', namespace => $namespace );
	$r->post('/asns/create')->over( authenticated => 1 )->to( 'Asn#create', namespace => $namespace );
	$r->get('/asns/:id/delete')->over( authenticated => 1 )->to( 'Asn#delete', namespace => $namespace );
	$r->post('/asns/:id/update')->over( authenticated => 1 )->to( 'Asn#update', namespace => $namespace );
	$r->route('/asns/:id/:mode')->via('GET')->over( authenticated => 1 )->to( 'Asn#view', namespace => $namespace );

	# -- CDNs
	$r->get('/cdns')->over( authenticated => 1 )->to( 'Cdn#index', namespace => $namespace );
	$r->get('/cdn/add')->over( authenticated => 1 )->to( 'Cdn#add', namespace => $namespace );
	$r->post('/cdn/create')->over( authenticated => 1 )->to( 'Cdn#create', namespace => $namespace );
	$r->get('/cdn/:id/delete')->over( authenticated => 1 )->to( 'Cdn#delete', namespace => $namespace );

	# mode is either 'edit' or 'view'.
	$r->route('/cdn/:mode/:id')->via('GET')->over( authenticated => 1 )->to( 'Cdn#view', namespace => $namespace );
	$r->post('/cdn/:id/update')->over( authenticated => 1 )->to( 'Cdn#update', namespace => $namespace );

	$r->get('/cdns/:cdn_name/dnsseckeys/add')->over( authenticated => 1 )->to( 'DnssecKeys#add', namespace => $namespace );
	$r->get('/cdns/:cdn_name/dnsseckeys/addksk')->over( authenticated => 1 )->to( 'DnssecKeys#addksk', namespace => $namespace );
	$r->post('/cdns/dnsseckeys/create')->over( authenticated => 1 )->to( 'DnssecKeys#create', namespace => $namespace );
	$r->post('/cdns/dnsseckeys/genksk')->over( authenticated => 1 )->to( 'DnssecKeys#genksk', namespace => $namespace );
	$r->get('/cdns/dnsseckeys')->to( 'DnssecKeys#index', namespace => $namespace );
	$r->get('/cdns/:cdn_name/dnsseckeys/manage')->over( authenticated => 1 )->to( 'DnssecKeys#manage', namespace => $namespace );
	$r->post('/cdns/dnsseckeys/activate')->over( authenticated => 1 )->to( 'DnssecKeys#activate', namespace => $namespace );

	# -- Dell - print boxes
	$r->get('/dells')->over( authenticated => 1 )->to( 'Dell#dells', namespace => $namespace );

	# -- Division
	$r->get('/divisions')->over( authenticated => 1 )->to( 'Division#index', namespace => $namespace );
	$r->get('/division/add')->over( authenticated => 1 )->to( 'Division#add', namespace => $namespace );
	$r->post('/division/create')->over( authenticated => 1 )->to( 'Division#create', namespace => $namespace );
	$r->get('/division/:id/edit')->over( authenticated => 1 )->to( 'Division#edit', namespace => $namespace );
	$r->post('/division/:id/update')->over( authenticated => 1 )->to( 'Division#update', namespace => $namespace );
	$r->get('/division/:id/delete')->over( authenticated => 1 )->to( 'Division#delete', namespace => $namespace );

	# -- DeliverysSrvice
	$r->get('/ds/add')->over( authenticated => 1 )->to( 'DeliveryService#add',  namespace => $namespace );
	$r->get('/ds/:id')->over( authenticated => 1 )->to( 'DeliveryService#edit', namespace => $namespace );
	$r->post('/ds/create')->over( authenticated => 1 )->to( 'DeliveryService#create', namespace => $namespace );
	$r->get('/ds/:id/delete')->over( authenticated => 1 )->to( 'DeliveryService#delete', namespace => $namespace );
	$r->post('/ds/:id/update')->over( authenticated => 1 )->to( 'DeliveryService#update', namespace => $namespace );

	# -- Keys - SSL Key management
	$r->get('/ds/:id/sslkeys/add')->to( 'SslKeys#add', namespace => $namespace );
	$r->post('/ds/sslkeys/create')->over( authenticated => 1 )->to( 'SslKeys#create', namespace => $namespace );

	# -- Keys - SSL Key management
	$r->get('/ds/:id/urlsigkeys/add')->to( 'UrlSigKeys#add', namespace => $namespace );

	# -- Steering DS assignment
	$r->get('/ds/:id/steering')->to( 'Steering#index', namespace => $namespace );
	$r->post('/ds/:id/steering/update')->over( authenticated => 1 )->to( 'Steering#update', namespace => $namespace );

	# JvD: ded route?? # $r->get('/ds_by_id/:id')->over( authenticated => 1 )->to('DeliveryService#ds_by_id', namespace => $namespace );
	$r->get('/healthdatadeliveryservice')->to( 'DeliveryService#readdeliveryservice', namespace => $namespace );
	$r->get('/delivery_services')->over( authenticated => 1 )->to( 'DeliveryService#index', namespace => $namespace );

	# -- DeliveryServiceserver
	$r->post('/dss/:id/update')->over( authenticated => 1 )->to( 'DeliveryServiceServer#assign_servers', namespace => $namespace )
		;    # update and create are the same... ?
	$r->post('/update/cpdss/:to_server')->over( authenticated => 1 )->to( 'DeliveryServiceServer#clone_server', namespace => $namespace );
	$r->route('/dss/:id/edit')->via('GET')->over( authenticated => 1 )->to( 'DeliveryServiceServer#edit', namespace => $namespace );
	$r->route('/cpdssiframe/:mode/:id')->via('GET')->over( authenticated => 1 )->to( 'DeliveryServiceServer#cpdss_iframe', namespace => $namespace );
	$r->post('/create/dsserver')->over( authenticated => 1 )->to( 'DeliveryServiceServer#create', namespace => $namespace );

	# -- DeliveryServiceTmuser
	$r->post('/dstmuser')->over( authenticated => 1 )->to( 'DeliveryServiceTmUser#create', namespace => $namespace );
	$r->get('/dstmuser/:ds/:tm_user_id/delete')->over( authenticated => 1 )->to( 'DeliveryServiceTmUser#delete', namespace => $namespace );

	# -- Federation
	$r->get('/federation')->over( authenticated => 1 )->to( 'Federation#index', namespace => $namespace );
	$r->get('/federation/:federation_id/delete')->name("federation_delete")->over( authenticated => 1 )->to( 'Federation#delete', namespace => $namespace );
	$r->get('/federation/:federation_id/edit')->name("federation_edit")->over( authenticated => 1 )->to( 'Federation#edit', namespace => $namespace );
	$r->get('/federation/add')->name('federation_add')->over( authenticated => 1 )->to( 'Federation#add', namespace => $namespace );
	$r->post('/federation')->name('federation_create')->to( 'Federation#create', namespace => $namespace );
	$r->post('/federation/:federation_id')->name('federation_update')->to( 'Federation#update', namespace => $namespace );
	$r->get("/federation/resolvers")->to( 'Federation#resolvers', namespace => $namespace );
	$r->get("/federation/users")->to( 'Federation#users', namespace => $namespace );
	$r->get( "/federation/resolvers")->to( 'Federation#resolvers', namespace => $namespace );
	$r->get( "/federation/users")->to( 'Federation#users',     namespace => $namespace );

	# -- Gendbdump - Get DB dump
	$r->get('/dbdump')->over( authenticated => 1 )->to( 'GenDbDump#dbdump', namespace => $namespace );

	# -- Geniso - From the Tools tab:
	$r->route('/geniso')->via('GET')->over( authenticated => 1 )->to( 'GenIso#geniso', namespace => $namespace );
	$r->route('/iso_download')->via('GET')->over( authenticated => 1 )->to( 'GenIso#iso_download', namespace => $namespace );

	# -- Hardware
	$r->get('/hardware')->over( authenticated => 1 )->to( 'Hardware#hardware', namespace => $namespace );
	$r->get('/hardware/:filter/:byvalue')->over( authenticated => 1 )->to( 'Hardware#hardware', namespace => $namespace );

	# -- Health - Parameters for rascal
	$r->get('/health')->to( 'Health#healthprofile', namespace => $namespace );
	$r->get('/healthfull')->to( 'Health#healthfull', namespace => $namespace );
	$r->get('/health/:cdnname')->to( 'Health#rascal_config', namespace => $namespace );

	# -- Job - These are for internal/agent job operations
	$r->post('/job/external/new')->to( 'Job#newjob', namespace => $namespace );
	$r->get('/job/external/view/:id')->to( 'Job#read_job_by_id', namespace => $namespace );
	$r->post('/job/external/cancel/:id')->to( 'Job#canceljob', namespace => $namespace );
	$r->get('/job/external/result/view/:id')->to( 'Job#readresult', namespace => $namespace );
	$r->get('/job/external/status/view/all')->to( 'Job#readstatus', namespace => $namespace );
	$r->get('/job/agent/viewpendingjobs/:id')->over( authenticated => 1 )->to( 'Job#viewagentjob', namespace => $namespace );
	$r->post('/job/agent/new')->over( authenticated => 1 )->to( 'Job#newagent', namespace => $namespace );
	$r->post('/job/agent/result/new')->over( authenticated => 1 )->to( 'Job#newresult', namespace => $namespace );
	$r->get('/job/agent/statusupdate/:id')->over( authenticated => 1 )->to( 'Job#jobstatusupdate', namespace => $namespace );
	$r->get('/job/agent/view/all')->over( authenticated => 1 )->to( 'Job#readagent', namespace => $namespace );
	$r->get('/job/view/all')->over( authenticated => 1 )->to( 'Job#listjob', namespace => $namespace );
	$r->get('/job/agent/new')->over( authenticated => 1 )->to( 'Job#addagent', namespace => $namespace );
	$r->get('/job/new')->over( authenticated => 1 )->to( 'Job#addjob', namespace => $namespace );
	$r->get('/jobs')->over( authenticated => 1 )->to( 'Job#jobs', namespace => $namespace );

	$r->get('/custom_charts')->over( authenticated => 1 )->to( 'CustomCharts#custom', namespace => $namespace );
	$r->get('/custom_charts_single')->over( authenticated => 1 )->to( 'CustomCharts#custom_single_chart', namespace => $namespace );
	$r->get('/custom_charts_single/cache/#cdn/#cdn_location/:cache/:stat')->over( authenticated => 1 )
		->to( 'CustomCharts#custom_single_chart', namespace => $namespace );
	$r->get('/custom_charts_single/ds/#cdn/#cdn_location/:ds/:stat')->over( authenticated => 1 )
		->to( 'CustomCharts#custom_single_chart', namespace => $namespace );
	$r->get('/uploadservercsv')->over( authenticated => 1 )->to( 'UploadServerCsv#uploadservercsv', namespace => $namespace );
	$r->get('/generic_uploader')->over( authenticated => 1 )->to( 'GenericUploader#generic', namespace => $namespace );
	$r->post('/upload_handler')->over( authenticated => 1 )->to( 'UploadHandler#upload', namespace => $namespace );
	$r->post('/uploadhandlercsv')->over( authenticated => 1 )->to( 'UploadHandlerCsv#upload', namespace => $namespace );

	# -- Cachegroupparameter
	$r->post('/cachegroupparameter/create')->over( authenticated => 1 )->to( 'CachegroupParameter#create', namespace => $namespace );
	$r->get('/cachegroupparameter/#cachegroup/#parameter/delete')->over( authenticated => 1 )->to( 'CachegroupParameter#delete', namespace => $namespace );

	# -- Options
	$r->options('/')->to( 'Cdn#options', namespace => $namespace );
	$r->options('/*')->to( 'Cdn#options', namespace => $namespace );

	# -- Ort
	$r->route('/ort/:hostname/ort1')->via('GET')->over( authenticated => 1 )->to( 'Ort#ort1', namespace => $namespace );
	$r->route('/ort/:hostname/packages')->via('GET')->over( authenticated => 1 )->to( 'Ort#get_package_versions', namespace => $namespace );
	$r->route('/ort/:hostname/chkconfig')->via('GET')->over( authenticated => 1 )->to( 'Ort#get_chkconfig', namespace => $namespace );

	# -- Parameter
	$r->post('/parameter/create')->over( authenticated => 1 )->to( 'Parameter#create', namespace => $namespace );
	$r->get('/parameter/:id/delete')->over( authenticated => 1 )->to( 'Parameter#delete', namespace => $namespace );
	$r->post('/parameter/:id/update')->over( authenticated => 1 )->to( 'Parameter#update', namespace => $namespace );
	$r->get('/parameters')->over( authenticated => 1 )->to( 'Parameter#index', namespace => $namespace );
	$r->get('/parameters/:filter/#byvalue')->over( authenticated => 1 )->to( 'Parameter#index', namespace => $namespace );
	$r->get('/parameter/add')->over( authenticated => 1 )->to( 'Parameter#add', namespace => $namespace );
	$r->route('/parameter/:id')->via('GET')->over( authenticated => 1 )->to( 'Parameter#view', namespace => $namespace );

	# -- PhysLocation
	$r->get('/phys_locations')->over( authenticated => 1 )->to( 'PhysLocation#index', namespace => $namespace );
	$r->post('/phys_location/create')->over( authenticated => 1 )->to( 'PhysLocation#create', namespace => $namespace );
	$r->get('/phys_location/add')->over( authenticated => 1 )->to( 'PhysLocation#add', namespace => $namespace );

	# mode is either 'edit' or 'view'.
	$r->route('/phys_location/:id/edit')->via('GET')->over( authenticated => 1 )->to( 'PhysLocation#edit', namespace => $namespace );
	$r->get('/phys_location/:id/delete')->over( authenticated => 1 )->to( 'PhysLocation#delete', namespace => $namespace );
	$r->post('/phys_location/:id/update')->over( authenticated => 1 )->to( 'PhysLocation#update', namespace => $namespace );

	# -- Profile
	$r->get('/profile/add')->over( authenticated => 1 )->to( 'Profile#add', namespace => $namespace );
	$r->get('/profile/edit/:id')->over( authenticated => 1 )->to( 'Profile#edit', namespace => $namespace );
	$r->route('/profile/:id/view')->via('GET')->over( authenticated => 1 )->to( 'Profile#view', namespace => $namespace );
	$r->route('/cmpprofile/:profile1/:profile2')->via('GET')->over( authenticated => 1 )->to( 'Profile#compareprofile', namespace => $namespace );
	$r->route('/cmpprofile/aadata/:profile1/:profile2')->via('GET')->over( authenticated => 1 )->to( 'Profile#acompareprofile', namespace => $namespace );
	$r->post('/profile/create')->over( authenticated => 1 )->to( 'Profile#create', namespace => $namespace );
	$r->get('/profile/import')->over( authenticated => 1 )->to( 'Profile#import', namespace => $namespace );
	$r->post('/profile/doImport')->over( authenticated => 1 )->to( 'Profile#doImport', namespace => $namespace );
	$r->get('/profile/:id/delete')->over( authenticated => 1 )->to( 'Profile#delete', namespace => $namespace );
	$r->post('/profile/:id/update')->over( authenticated => 1 )->to( 'Profile#update', namespace => $namespace );

	# select available Profile, DS or Server
	$r->get('/availableprofile/:paramid')->over( authenticated => 1 )->to( 'Profile#availableprofile', namespace => $namespace );
	$r->route('/profile/:id/export')->via('GET')->over( authenticated => 1 )->to( 'Profile#export', namespace => $namespace );
	$r->get('/profiles')->over( authenticated => 1 )->to( 'Profile#index', namespace => $namespace );

	# -- Profileparameter
	$r->post('/profileparameter/create')->over( authenticated => 1 )->to( 'ProfileParameter#create', namespace => $namespace );
	$r->get('/profileparameter/:profile/:parameter/delete')->over( authenticated => 1 )->to( 'ProfileParameter#delete', namespace => $namespace );

	# -- Rascalstatus
	$r->get('/edge_health')->over( authenticated => 1 )->to( 'RascalStatus#health', namespace => $namespace );
	$r->get('/rascalstatus')->over( authenticated => 1 )->to( 'RascalStatus#health', namespace => $namespace );

	# -- Region
	$r->get('/regions')->over( authenticated => 1 )->to( 'Region#index', namespace => $namespace );
	$r->get('/region/add')->over( authenticated => 1 )->to( 'Region#add', namespace => $namespace );
	$r->post('/region/create')->over( authenticated => 1 )->to( 'Region#create', namespace => $namespace );
	$r->get('/region/:id/edit')->over( authenticated => 1 )->to( 'Region#edit', namespace => $namespace );
	$r->post('/region/:id/update')->over( authenticated => 1 )->to( 'Region#update', namespace => $namespace );
	$r->get('/region/:id/delete')->over( authenticated => 1 )->to( 'Region#delete', namespace => $namespace );

	# -- Server
	$r->post('/server/:name/status/:state')->over( authenticated => 1 )->to( 'Server#rest_update_server_status', namespace => $namespace );
	$r->get('/server/:name/status')->over( authenticated => 1 )->to( 'Server#get_server_status', namespace => $namespace );
	$r->get('/servers')->over( authenticated => 1 )->to( 'Server#index', namespace => $namespace );
	$r->get('/server/add')->over( authenticated => 1 )->to( 'Server#add', namespace => $namespace );
	$r->post('/server/:id/update')->over( authenticated => 1 )->to( 'Server#update', namespace => $namespace );
	$r->get('/server/:id/delete')->over( authenticated => 1 )->to( 'Server#delete', namespace => $namespace );
	$r->route('/server/:id/:mode')->via('GET')->over( authenticated => 1 )->to( 'Server#view', namespace => $namespace );
	$r->post('/server/create')->over( authenticated => 1 )->to( 'Server#create', namespace => $namespace );
	$r->post('/server/updatestatus')->over( authenticated => 1 )->to( 'Server#updatestatus', namespace => $namespace );

	# -- Serverstatus
	$r->get('/server_check')->to( 'server_check#server_check', namespace => $namespace );

	# -- Staticdnsentry
	$r->route('/staticdnsentry/:id/edit')->via('GET')->over( authenticated => 1 )->to( 'StaticDnsEntry#edit', namespace => $namespace );
	$r->post('/staticdnsentry/:dsid/update')->over( authenticated => 1 )->to( 'StaticDnsEntry#update_assignments', namespace => $namespace );
	$r->get('/staticdnsentry/:id/delete')->over( authenticated => 1 )->to( 'StaticDnsEntry#delete', namespace => $namespace );

	# -- Status
	$r->post('/status/create')->over( authenticated => 1 )->to( 'Status#create', namespace => $namespace );
	$r->get('/status/delete/:id')->over( authenticated => 1 )->to( 'Status#delete', namespace => $namespace );
	$r->post('/status/update/:id')->over( authenticated => 1 )->to( 'Status#update', namespace => $namespace );

	# -- Tools
	$r->get('/tools')->over( authenticated => 1 )->to( 'Tools#tools', namespace => $namespace );
	$r->get('/tools/db_dump')->over( authenticated => 1 )->to( 'Tools#db_dump', namespace => $namespace );
	$r->get('/tools/queue_updates')->over( authenticated => 1 )->to( 'Tools#queue_updates', namespace => $namespace );
	$r->get('/tools/snapshot_crconfig')->over( authenticated => 1 )->to( 'Tools#snapshot_crconfig', namespace => $namespace );
	$r->get('/tools/diff_crconfig/:cdn_name')->over( authenticated => 1 )->to( 'Tools#diff_crconfig_iframe', namespace => $namespace );
	$r->get('/tools/write_crconfig/:cdn_name')->over( authenticated => 1 )->to( 'Tools#write_crconfig', namespace => $namespace );
	$r->get('/tools/invalidate_content/')->over( authenticated => 1 )->to( 'Tools#invalidate_content', namespace => $namespace );

	# -- Topology - CCR Config, rewrote in json
	$r->route('/genfiles/:mode/bycdnname/:cdnname/CRConfig')->via('GET')->over( authenticated => 1 )->to( 'Topology#ccr_config', namespace => $namespace );
	$r->get('/CRConfig-Snapshots/:cdn_name/CRConfig.json')->over( authenticated => 1 )->to( 'Snapshot#get_cdn_snapshot', namespace => $namespace );

	$r->get('/types')->over( authenticated => 1 )->to( 'Types#index', namespace => $namespace );
	$r->route('/types/add')->via('GET')->over( authenticated => 1 )->to( 'Types#add', namespace => $namespace );
	$r->route('/types/create')->via('POST')->over( authenticated => 1 )->to( 'Types#create', namespace => $namespace );
	$r->route('/types/:id/update')->over( authenticated => 1 )->to( 'Types#update', namespace => $namespace );
	$r->route('/types/:id/delete')->over( authenticated => 1 )->to( 'Types#delete', namespace => $namespace );
	$r->route('/types/:id/:mode')->via('GET')->over( authenticated => 1 )->to( 'Types#view', namespace => $namespace );

	# -- Update bit - Process updates - legacy stuff.
	$r->get('/update/:host_name')->over( authenticated => 1 )->to( 'Server#readupdate', namespace => $namespace );
	$r->post('/update/:host_name')->over( authenticated => 1 )->to( 'Server#postupdate', namespace => $namespace );
	$r->post('/postupdatequeue/:id')->over( authenticated => 1 )->to( 'Server#postupdatequeue', namespace => $namespace );
	$r->post('/postupdatequeue/:cdn/#cachegroup')->over( authenticated => 1 )->to( 'Server#postupdatequeue', namespace => $namespace );

	# -- User
	$r->post('/user/register/send')->over( authenticated => 1 )->name('user_register_send')->to( 'User#send_registration', namespace => $namespace );
	$r->get('/users')->name("user_index")->over( authenticated => 1 )->to( 'User#index', namespace => $namespace );
	$r->get('/user/:id/edit')->name("user_edit")->over( authenticated => 1 )->to( 'User#edit', namespace => $namespace );
	$r->get('/user/add')->name('user_add')->over( authenticated => 1 )->to( 'User#add', namespace => $namespace );
	$r->get('/user/register')->name('user_register')->to( 'User#register', namespace => $namespace );
	$r->post('/user/:id/reset_password')->name('user_reset_password')->to( 'User#reset_password', namespace => $namespace );
	$r->post('/user')->name('user_create')->to( 'User#create', namespace => $namespace );
	$r->post('/user/:id')->name('user_update')->to( 'User#update', namespace => $namespace );

	# -- Utils
	$r->get('/utils/close_fancybox')->over( authenticated => 1 )->to( 'Utils#close_fancybox', namespace => $namespace );

	# -- Visualstatus
	$r->get('/visualstatus/:matchstring')->over( authenticated => 1 )->to( 'VisualStatus#graphs', namespace => $namespace );
	$r->get('/dailysummary')->over( authenticated => 1 )->to( 'VisualStatus#daily_summary', namespace => $namespace );

	# deprecated - see: /api/$version/servers and /api/1.1/servers/hostname/:host_name/details
	# duplicate route
	$r->get('/healthdataserver')->to( 'Server#index_response', namespace => $namespace );

	# select * from table where id=ID;
	$r->get('/server_by_id/:id')->over( authenticated => 1 )->to( 'Server#server_by_id', namespace => $namespace );

}

sub api_routes {
	my $self      = shift;
	my $r         = shift;
	my $version   = shift;
	my $namespace = shift;

	# -- ASNS (CRANS)
	$r->get("/api/1.1/asns")->over( authenticated => 1 )->to( 'Asn#v11_index', namespace => $namespace );
	$r->get("/api/1.2/asns")->over( authenticated => 1 )->to( 'Asn#index',     namespace => $namespace );
	$r->get( "/api/1.2/asns/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Asn#show', namespace => $namespace );
	$r->post("/api/$version/asns")->over( authenticated => 1 )->to( 'Asn#create', namespace => $namespace );
	$r->put("/api/$version/asns/:id")->over( authenticated => 1 )->to( 'Asn#update', namespace => $namespace );
	$r->delete("/api/$version/asns/:id")->over( authenticated => 1 )->to( 'Asn#delete', namespace => $namespace );

	# -- CACHEGROUPS
	# -- CACHEGROUPS: CRUD
	# NOTE: any 'trimmed' urls will potentially go away with keys= support
	# -- query parameter options ?orderby=key&keys=name (where key is the database column)
	$r->get("/api/$version/cachegroups")->over( authenticated => 1 )->to( 'Cachegroup#index', namespace => $namespace );
	$r->get("/api/$version/cachegroups/trimmed")->over( authenticated => 1 )->to( 'Cachegroup#index_trimmed', namespace => $namespace );
	$r->get( "/api/$version/cachegroups/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Cachegroup#show', namespace => $namespace );
	$r->post("/api/$version/cachegroups")->over( authenticated => 1 )->to( 'Cachegroup#create', namespace => $namespace );
	$r->put("/api/$version/cachegroups/:id")->over( authenticated => 1 )->to( 'Cachegroup#update', namespace => $namespace );
	$r->delete("/api/$version/cachegroups/:id")->over( authenticated => 1 )->to( 'Cachegroup#delete', namespace => $namespace );

	$r->get( "/api/$version/cachegroups/:id/parameters")->over( authenticated => 1 )->to( 'Parameter#get_cachegroup_params', namespace => $namespace );

	# alternate cachegroup routes
	$r->get("/api/$version/cachegroups/list")->over( authenticated => 1 )->to( 'Cachegroup2#index', namespace => $namespace );
	$r->post("/api/$version/cachegroups/create")->over( authenticated => 1 )->to( 'Cachegroup2#create', namespace => $namespace );
	$r->put("/api/$version/cachegroups/:id/update")->over( authenticated => 1 )->to( 'Cachegroup2#update', namespace => $namespace );
	$r->delete("/api/$version/cachegroups/:id/delete")->over( authenticated => 1 )->to( 'Cachegroup2#delete', namespace => $namespace );

	# -- CACHEGROUPS: ASSIGN DELIVERYSERVICES
	$r->post("/api/$version/cachegroups/:id/deliveryservices")->over( authenticated => 1 )
		->to( 'DeliveryServiceServer#assign_ds_to_cachegroup', namespace => $namespace );

	# -- CACHEGROUPS: QUEUE UPDATES
	$r->post("/api/$version/cachegroups/:id/queue_update")->over( authenticated => 1 )->to( 'Cachegroup#postupdatequeue', namespace => $namespace );

	# -- CDNS
	# -- CDNS: CRUD
	$r->get("/api/$version/cdns")->over( authenticated => 1 )->to( 'Cdn#index', namespace => $namespace );
	$r->get( "/api/$version/cdns/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Cdn#show', namespace => $namespace );
	$r->get("/api/$version/cdns/name/:name")->over( authenticated => 1 )->to( 'Cdn#name', namespace => $namespace );
	$r->post("/api/$version/cdns")->over( authenticated => 1 )->to( 'Cdn#create', namespace => $namespace );
	$r->put("/api/$version/cdns/:id")->over( authenticated => 1 )->to( 'Cdn#update', namespace => $namespace );
	$r->delete("/api/$version/cdns/:id")->over( authenticated => 1 )->to( 'Cdn#delete', namespace => $namespace );

	# -- CDNS: QUEUE UPDATES
	$r->post("/api/$version/cdns/:id/queue_update")->over( authenticated => 1 )->to( 'Cdn#queue_updates', namespace => $namespace );

	# -- CDNS: HEALTH
	$r->get("/api/$version/cdns/health")->over( authenticated => 1 )->to( 'Cdn#health', namespace => $namespace );
	$r->get("/api/$version/cdns/:name/health")->over( authenticated => 1 )->to( 'Cdn#health', namespace => $namespace );

	# -- CDNS: CAPACITY
	$r->get("/api/$version/cdns/capacity")->over( authenticated => 1 )->to( 'Cdn#capacity', namespace => $namespace );

	# -- CDNS: ROUTING
	$r->get("/api/$version/cdns/routing")->over( authenticated => 1 )->to( 'Cdn#routing', namespace => $namespace );

	# -- CDNS: SNAPSHOT
	$r->put( "/api/$version/cdns/:id/snapshot" => [ id => qr/\d+/ ] )->over( authenticated => 1 )
		->to( 'Topology#SnapshotCRConfig', namespace => $namespace );
	$r->put("/api/$version/snapshot/:cdn_name")->over( authenticated => 1 )->to( 'Topology#SnapshotCRConfig', namespace => $namespace );

	# -- CDNS: METRICS
	#WARNING: this is an intentionally "unauthenticated" route.
	$r->get("/api/$version/cdns/metric_types/:metric_type/start_date/:start_date/end_date/:end_date")->to( 'Cdn#metrics', namespace => $namespace );

	# -- CDNS: DNSSEC KEYS
	# Support for DNSSEC zone signing, key signing, and private keys
	# gets the latest key by default unless a version query param is provided with ?version=x
	$r->get("/api/$version/cdns/name/:name/dnsseckeys")->over( authenticated => 1 )->to( 'Cdn#dnssec_keys', namespace => $namespace );

	# generate new dnssec keys
	$r->post("/api/$version/cdns/dnsseckeys/generate")->over( authenticated => 1 )->to( 'Cdn#dnssec_keys_generate', namespace => $namespace );

	# delete dnssec keys
	$r->get("/api/$version/cdns/name/:name/dnsseckeys/delete")->over( authenticated => 1 )->to( 'Cdn#delete_dnssec_keys', namespace => $namespace );

	# checks expiration of keys and re-generates if necessary.  Used by Cron.
	$r->get("/internal/api/$version/cdns/dnsseckeys/refresh")->to( 'Cdn#dnssec_keys_refresh', namespace => $namespace );

	# -- CDNS: SSL KEYS
	$r->get("/api/$version/cdns/name/:name/sslkeys")->over( authenticated => 1 )->to( 'Cdn#ssl_keys', namespace => $namespace );

	# -- CDN: TOPOLOGY
	$r->get("/api/$version/cdns/configs")->via('GET')->over( authenticated => 1 )->to( 'Cdn#get_cdns', namespace => $namespace );
	$r->get("/api/$version/cdns/:name/configs/routing")->via('GET')->over( authenticated => 1 )->to( 'Cdn#configs_routing', namespace => $namespace );
	$r->get("/api/$version/cdns/:name/configs/monitoring")->via('GET')->over( authenticated => 1 )->to( 'Cdn#configs_monitoring', namespace => $namespace );

	# -- CDN: DOMAINS
	$r->get("/api/$version/cdns/domains")->over( authenticated => 1 )->to( 'Cdn#domains', namespace => $namespace );

	# -- CHANGE LOGS
	$r->get("/api/$version/logs")->over( authenticated => 1 )->to( 'ChangeLog#index', namespace => $namespace );
	$r->get("/api/$version/logs/:days/days")->over( authenticated => 1 )->to( 'ChangeLog#index', namespace => $namespace );
	$r->get("/api/$version/logs/newcount")->over( authenticated => 1 )->to( 'ChangeLog#newlogcount', namespace => $namespace );

	# -- CONFIG FILES
	$r->get("/api/$version/server/:id/configfiles/ats")->over( authenticated => 1 )->to ( 'ApacheTrafficServer#ort', namespace => 'API::Configs' );
	$r->get("/api/$version/profile/:id/configfiles/ats/#filename")->over( authenticated => 1 )->to ( 'ApacheTrafficServer#get_profile_config', namespace => 'API::Configs' );
	$r->get("/api/$version/server/:id/configfiles/ats/#filename")->over( authenticated => 1 )->to ( 'ApacheTrafficServer#get_server_config', namespace => 'API::Configs' );
	$r->get("/api/$version/cdn/:id/configfiles/ats/#filename")->over( authenticated => 1 )->to ( 'ApacheTrafficServer#get_cdn_config', namespace => 'API::Configs' );

	# -- DELIVERYSERVICES
	# -- DELIVERYSERVICES: CRUD
	$r->get("/api/$version/deliveryservices")->over( authenticated => 1 )->to( 'Deliveryservice#index', namespace => $namespace );
	$r->get( "/api/$version/deliveryservices/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Deliveryservice#show', namespace => $namespace );
	$r->post("/api/$version/deliveryservices")->over( authenticated => 1 )->to( 'Deliveryservice#create', namespace => $namespace );
	$r->put("/api/$version/deliveryservices/:id")->over( authenticated => 1 )->to( 'Deliveryservice#update', namespace => $namespace );
	$r->delete("/api/$version/deliveryservices/:id")->over( authenticated => 1 )->to( 'Deliveryservice#delete', namespace => $namespace );

	# get all edge servers associated with a delivery service (from deliveryservice_server table)
	$r->get( "/api/$version/deliveryservices/:id/servers")->over( authenticated => 1 )->to( 'Server#get_edge_servers_by_dsid', namespace => $namespace );

	# alternate deliveryservice routes
	$r->get("/api/$version/deliveryservices/list")->over( authenticated => 1 )->to( 'Deliveryservice2#delivery_services', namespace => $namespace );
	$r->get( "/api/$version/deliveryservices/:id/get" => [ id => qr/\d+/ ] )->over( authenticated => 1 )
		->to( 'Deliveryservice2#delivery_services', namespace => $namespace );
	$r->post("/api/$version/deliveryservices/create")->over( authenticated => 1 )->to( 'Deliveryservice2#create', namespace => $namespace );
	$r->put("/api/$version/deliveryservices/:id/update")->over( authenticated => 1 )->to( 'Deliveryservice2#update', namespace => $namespace );
	$r->post("/api/$version/deliveryservices/:xml_id/servers")->over( authenticated => 1 )
		->to( 'Deliveryservice2#assign_servers', namespace => $namespace );

	# -- DELIVERYSERVICES: HEALTH
	$r->get("/api/$version/deliveryservices/:id/health")->over( authenticated => 1 )->to( 'Deliveryservice#health', namespace => $namespace );

	# -- DELIVERYSERVICES: CAPACITY
	$r->get("/api/$version/deliveryservices/:id/capacity")->over( authenticated => 1 )->to( 'Deliveryservice#capacity', namespace => $namespace );

	# -- DELIVERYSERVICES: ROUTING
	$r->get("/api/$version/deliveryservices/:id/routing")->over( authenticated => 1 )->to( 'Deliveryservice#routing', namespace => $namespace );

	# -- DELIVERYSERVICES: STATE
	$r->get("/api/$version/deliveryservices/:id/state")->over( authenticated => 1 )->to( 'Deliveryservice#state', namespace => $namespace );

	# -- DELIVERYSERVICES: REQUEST NEW DELIVERY SERVICE
	$r->post("/api/$version/deliveryservices/request")->over( authenticated => 1 )->to( 'Deliveryservice#request', namespace => $namespace );

	# -- DELIVERYSERVICES: STEERING DELIVERYSERVICES
	$r->get("/internal/api/$version/steering")->over( authenticated => 1 )->to( 'Steering#index', namespace => 'API::DeliveryService' );
	$r->get("/internal/api/$version/steering/:xml_id")->over( authenticated => 1 )->to( 'Steering#index', namespace => 'API::DeliveryService' );
	$r->post("/internal/api/$version/steering")->over( authenticated => 1 )->to( 'Steering#add', namespace => 'API::DeliveryService' );
	$r->put("/internal/api/$version/steering/:xml_id")->over( authenticated => 1 )->to( 'Steering#update', namespace => 'API::DeliveryService' );

	# -- DELIVERYSERVICE: SSL KEYS
	# Support for SSL private keys, certs, and csrs
	# gets the latest key by default unless a version query param is provided with ?version=x
	$r->get("/api/$version/deliveryservices/xmlId/#xmlid/sslkeys")->over( authenticated => 1 )
		->to( 'SslKeys#view_by_xml_id', namespace => 'API::DeliveryService' );
	$r->get("/api/$version/deliveryservices/hostname/#hostname/sslkeys")->over( authenticated => 1 )
		->to( 'SslKeys#view_by_hostname', namespace => 'API::DeliveryService' );

	# generate new ssl keys for a delivery service
	$r->post("/api/$version/deliveryservices/sslkeys/generate")->over( authenticated => 1 )->to( 'SslKeys#generate', namespace => 'API::DeliveryService' );

	# add existing ssl keys to a delivery service
	$r->post("/api/$version/deliveryservices/sslkeys/add")->over( authenticated => 1 )->to( 'SslKeys#add', namespace => 'API::DeliveryService' );

	# deletes the latest key by default unless a version query param is provided with ?version=x
	$r->get("/api/$version/deliveryservices/xmlId/:xmlid/sslkeys/delete")->over( authenticated => 1 )
		->to( 'SslKeys#delete', namespace => 'API::DeliveryService' );

	# -- DELIVERY SERVICE: URL SIG KEYS
	$r->post("/api/$version/deliveryservices/xmlId/:xmlId/urlkeys/generate")->over( authenticated => 1 )
		->to( 'KeysUrlSig#generate', namespace => 'API::DeliveryService' );
	$r->get("/api/$version/deliveryservices/xmlId/:xmlId/urlkeys")->over( authenticated => 1 )
		->to( 'KeysUrlSig#view_by_xmlid', namespace => 'API::DeliveryService' );

	# -- DELIVERY SERVICE: REGEXES
	$r->get("/api/$version/deliveryservices_regexes")->over( authenticated => 1 )->to( 'DeliveryServiceRegexes#all', namespace => $namespace );
	$r->get("/api/$version/deliveryservices/:dsId/regexes")->over( authenticated => 1 )->to( 'DeliveryServiceRegexes#index', namespace => $namespace );
	$r->get("/api/$version/deliveryservices/:dsId/regexes/:id")->over( authenticated => 1 )->to( 'DeliveryServiceRegexes#show', namespace => $namespace );
	$r->post("/api/$version/deliveryservices/:dsId/regexes")->over( authenticated => 1 )->to( 'DeliveryServiceRegexes#create', namespace => $namespace );
	$r->put("/api/$version/deliveryservices/:dsId/regexes/:id")->over( authenticated => 1 )->to( 'DeliveryServiceRegexes#update', namespace => $namespace );
	$r->delete("/api/$version/deliveryservices/:dsId/regexes/:id")->over( authenticated => 1 )->to( 'DeliveryServiceRegexes#delete', namespace => $namespace );

	# -- DELIVERY SERVICE: MATCHES
	$r->get("/api/$version/deliveryservice_matches")->over( authenticated => 1 )->to( 'DeliveryServiceMatches#index', namespace => $namespace );

	# -- DELIVERYSERVICES: SERVERS
	# Supports ?orderby=key
	$r->get("/api/$version/deliveryserviceserver")->over( authenticated => 1 )->to( 'DeliveryServiceServer#index', namespace => $namespace );

	# -- DIVISIONS
	$r->get("/api/$version/divisions")->over( authenticated => 1 )->to( 'Division#index', namespace => $namespace );
	$r->get( "/api/$version/divisions/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Division#show', namespace => $namespace );
	$r->get( "/api/$version/divisions/name/:name")->over( authenticated => 1 )->to( 'Division#index_by_name', namespace => $namespace );
	$r->put("/api/$version/divisions/:id")->over( authenticated => 1 )->to( 'Division#update', namespace => $namespace );
	$r->post("/api/$version/divisions")->over( authenticated => 1 )->to( 'Division#create', namespace => $namespace );
	$r->delete("/api/$version/divisions/:id")->over( authenticated => 1 )->to( 'Division#delete', namespace => $namespace );
	$r->delete("/api/$version/divisions/name/:name")->over( authenticated => 1 )->to( 'Division#delete_by_name', namespace => $namespace );

	# -- FEDERATIONS
	$r->get("/internal/api/$version/federations")->over( authenticated => 1 )->to( 'Federation#index', namespace => $namespace );
	$r->get("/api/$version/federations")->over( authenticated => 1 )->to( 'Federation#external_index', namespace => $namespace );
	$r->post("/api/$version/federations")->over( authenticated => 1 )->to( 'Federation#add', namespace => $namespace );
	$r->delete("/api/$version/federations")->over( authenticated => 1 )->to( 'Federation#delete', namespace => $namespace );
	$r->put("/api/$version/federations")->over( authenticated => 1 )->to( 'Federation#update', namespace => $namespace );

	# -- HARDWARE INFO
	# Supports: ?orderby=key
	$r->get("/api/$version/hwinfo/dtdata")->over( authenticated => 1 )->to( 'HwInfo#data', namespace => $namespace );
	$r->get("/api/$version/hwinfo")->over( authenticated => 1 )->to( 'HwInfo#index', namespace => $namespace );

	# -- PARAMETERS
	# Supports ?orderby=key
	$r->get("/api/$version/parameters")->over( authenticated => 1 )->to( 'Parameter#index', namespace => $namespace );
	$r->get( "/api/$version/parameters/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Parameter#get', namespace => $namespace );
	$r->post("/api/$version/parameters")->over( authenticated => 1 )->to( 'Parameter#create', namespace => $namespace );
	$r->put("/api/$version/parameters/:id")->over( authenticated => 1 )->to( 'Parameter#edit', namespace => $namespace );
	$r->delete("/api/$version/parameters/:id")->over( authenticated => 1 )->to( 'Parameter#delete', namespace => $namespace );
	$r->post("/api/$version/parameters/validate")->over( authenticated => 1 )->to( 'Parameter#validate', namespace => $namespace );

	# get all profiles associated with a parameter (from profile_parameter table)
	$r->get( "/api/$version/parameters/:id/profiles")->over( authenticated => 1 )->to( 'Profile#get_profiles_by_paramId', namespace => $namespace );

	# parameters for a profile
	$r->get( "/api/$version/profiles/:id/parameters" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Parameter#get_profile_params', namespace => $namespace );
	$r->get("/api/$version/profiles/name/:name/parameters")->over( authenticated => 1 )->to( 'Parameter#get_profile_params', namespace => $namespace );
	$r->get( "/api/$version/parameters/profile/:name")->over( authenticated => 1 )->to( 'Parameter#get_profile_params', namespace => $namespace );
	$r->post("/api/$version/profiles/name/:name/parameters")->over( authenticated => 1 )
		->to( 'ProfileParameter#create_param_for_profile_name', namespace => $namespace );
	$r->post("/api/$version/profiles/:id/parameters")->over( authenticated => 1 )
		->to( 'ProfileParameter#create_param_for_profile_id', namespace => $namespace );

	# -- PARAMETERS: PROFILE PARAMETERS
	$r->get("/api/$version/profileparameters")->over( authenticated => 1 )->to( 'ProfileParameter#index', namespace => $namespace );
	$r->post("/api/$version/profileparameters")->over( authenticated => 1 )->to( 'ProfileParameter#create', namespace => $namespace );
	$r->delete("/api/$version/profileparameters/:profile_id/:parameter_id")->over( authenticated => 1 )
		->to( 'ProfileParameter#delete', namespace => $namespace );

	# -- PARAMETERS: CACHEGROUP PARAMETERS
	$r->get("/api/$version/cachegroup/:parameter_id/parameter")->over( authenticated => 1 )->to( 'Cachegroup#by_parameter_id', namespace => $namespace );
	$r->get("/api/$version/cachegroupparameters")->over( authenticated => 1 )->to( 'CachegroupParameter#index', namespace => $namespace );
	$r->get("/api/$version/cachegroups/:parameter_id/parameter/available")->over( authenticated => 1 )
		->to( 'Cachegroup#available_for_parameter', namespace => $namespace );

	# -- PHYS_LOCATION
	# Supports ?orderby=key
	$r->get("/api/$version/phys_locations")->over( authenticated => 1 )->to( 'PhysLocation#index', namespace => $namespace );
	$r->get("/api/$version/phys_locations/trimmed")->over( authenticated => 1 )->to( 'PhysLocation#index_trimmed', namespace => $namespace );
	$r->get( "/api/$version/phys_locations/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'PhysLocation#show', namespace => $namespace );
	$r->post("/api/$version/phys_locations")->over( authenticated => 1 )->to( 'PhysLocation#create', namespace => $namespace );
	$r->put("/api/$version/phys_locations/:id")->over( authenticated => 1 )->to( 'PhysLocation#update', namespace => $namespace );
	$r->delete("/api/$version/phys_locations/:id")->over( authenticated => 1 )->to( 'PhysLocation#delete', namespace => $namespace );

	# -- PROFILES
	# -- PROFILES: CRUD
	# Supports ?orderby=key
	$r->get("/api/$version/profiles")->over( authenticated => 1 )->to( 'Profile#index', namespace => $namespace );
	$r->get("/api/$version/profiles/trimmed")->over( authenticated => 1 )->to( 'Profile#index_trimmed', namespace => $namespace );
	$r->get( "/api/$version/profiles/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Profile#show', namespace => $namespace );
	$r->post("/api/$version/profiles")->over( authenticated => 1 )->to( 'Profile#create', namespace => $namespace );
	$r->put("/api/$version/profiles/:id")->over( authenticated => 1 )->to( 'Profile#update', namespace => $namespace );
	$r->delete("/api/$version/profiles/:id")->over( authenticated => 1 )->to( 'Profile#delete', namespace => $namespace );

	# -- PROFILES: COPY
	$r->post("/api/$version/profiles/name/:profile_name/copy/:profile_copy_from")->over( authenticated => 1 )
		->to( 'Profile#copy', namespace => $namespace );

	# -- REGIONS
	# Supports ?orderby=key
	$r->get("/api/$version/regions")->over( authenticated => 1 )->to( 'Region#index', namespace => $namespace );
	$r->get( "/api/$version/regions/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Region#show', namespace => $namespace );
	$r->get( "/api/$version/regions/name/:name" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Region#index_by_name', namespace => $namespace );
	$r->put("/api/$version/regions/:id")->over( authenticated => 1 )->to( 'Region#update', namespace => $namespace );
	$r->post("/api/$version/regions")->over( authenticated => 1 )->to( 'Region#create', namespace => $namespace );
	$r->post("/api/$version/divisions/:division_name/regions")->over( authenticated => 1 )->to( 'Region#create_for_division', namespace => $namespace );
	$r->delete("/api/$version/regions/:id")->over( authenticated => 1 )->to( 'Region#delete', namespace => $namespace );
	$r->delete("/api/$version/regions/name/:name")->over( authenticated => 1 )->to( 'Region#delete_by_name', namespace => $namespace );
	$r->post("/api/$version/regions/:region_name/phys_locations")->over( authenticated => 1 )->to( 'PhysLocation#create_for_region', namespace => $namespace );

	# -- ROLES
	# Supports ?orderby=key
	$r->get("/api/$version/roles")->over( authenticated => 1 )->to( 'Role#index', namespace => $namespace );

	# -- SERVERS
	# -- SERVERS: CRUD
	$r->get("/api/$version/servers")->over( authenticated => 1 )->to( 'Server#index', namespace => $namespace );
	$r->get( "/api/$version/servers/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Server#show', namespace => $namespace );
	$r->post("/api/$version/servers")->over( authenticated => 1 )->to( 'Server#create', namespace => $namespace );
	$r->put("/api/$version/servers/:id")->over( authenticated => 1 )->to( 'Server#update', namespace => $namespace );
	$r->delete("/api/$version/servers/:id")->over( authenticated => 1 )->to( 'Server#delete', namespace => $namespace );

	# get all delivery services associated with a server (from deliveryservice_server table)
	$r->get( "/api/$version/servers/:id/deliveryservices")->over( authenticated => 1 )->to( 'Deliveryservice#get_deliveryservices_by_serverId', namespace => $namespace );

	# alernate server routes
	$r->post("/api/$version/servers/create")->over( authenticated => 1 )->to( 'Server2#create', namespace => $namespace );
	$r->put("/api/$version/servers/:id/update")->over( authenticated => 1 )->to( 'Server2#update', namespace => $namespace );

	# -- SERVERS: DETAILS
	$r->get("/api/$version/servers/details")->over( authenticated => 1 )->to( 'Server#details', namespace => $namespace );
	$r->get("/api/$version/servers/hostname/:name/details")->over( authenticated => 1 )->to( 'Server#details_v11', namespace => $namespace );

	# -- SERVERS: TOTALS
	$r->get("/api/$version/servers/totals")->over( authenticated => 1 )->to( 'Server#totals', namespace => $namespace );

	# -- SERVERS: QUEUE UPDATES
	$r->post("/api/$version/servers/:id/queue_update")->over( authenticated => 1 )->to( 'Server#postupdatequeue', namespace => $namespace );

	# -- SERVERS: SERVER CHECKS
	$r->get("/api/$version/servers/checks")->over( authenticated => 1 )->to( 'ServerCheck#read', namespace => $namespace );
	$r->get("/api/$version/servercheck/aadata")->over( authenticated => 1 )->to( 'ServerCheck#aadata', namespace => $namespace );
	$r->post("/api/$version/servercheck")->over( authenticated => 1 )->to( 'ServerCheck#update', namespace => $namespace );

	# -- STATS
	$r->get("/api/$version/stats_summary")->over( authenticated => 1 )->to( 'StatsSummary#index', namespace => $namespace );
	$r->post("/api/$version/stats_summary/create")->over( authenticated => 1 )->to( 'StatsSummary#create', namespace => $namespace );

	# -- STATUSES
	# Supports ?orderby=key
	$r->get("/api/$version/statuses")->over( authenticated => 1 )->to( 'Status#index', namespace => $namespace );
	$r->get( "/api/$version/statuses/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Status#show', namespace => $namespace );
	$r->put("/api/$version/statuses/:id")->over( authenticated => 1 )->to( 'Status#update', namespace => $namespace );
	$r->post("/api/$version/statuses")->over( authenticated => 1 )->to( 'Status#create', namespace => $namespace );
	$r->delete("/api/$version/statuses/:id")->over( authenticated => 1 )->to( 'Status#delete', namespace => $namespace );

	# -- STATIC DNS ENTRIES
	$r->get("/api/$version/staticdnsentries")->over( authenticated => 1 )->to( 'StaticDnsEntry#index', namespace => $namespace );

	# -- SYSTEM INFO
	$r->get("/api/$version/system/info")->over( authenticated => 1 )->to( 'System#get_info', namespace => $namespace );

	# -- TYPES
	# Supports ?orderby=key
	$r->get("/api/$version/types")->over( authenticated => 1 )->to( 'Types#index', namespace => $namespace );
	$r->get("/api/$version/types/trimmed")->over( authenticated => 1 )->to( 'Types#index_trimmed', namespace => $namespace );
	$r->get( "/api/$version/types/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'Types#show', namespace => $namespace );
	$r->post("/api/$version/types")->over( authenticated => 1 )->to( 'Types#create', namespace => $namespace );
	$r->put("/api/$version/types/:id")->over( authenticated => 1 )->to( 'Types#update', namespace => $namespace );
	$r->delete("/api/$version/types/:id")->over( authenticated => 1 )->to( 'Types#delete', namespace => $namespace );

	# -- USERS
	$r->get("/api/$version/users")->over( authenticated => 1 )->to( 'User#index', namespace => $namespace );
	$r->get( "/api/$version/users/:id" => [ id => qr/\d+/ ] )->over( authenticated => 1 )->to( 'User#show', namespace => $namespace );
	$r->put("/api/$version/users/:id")->over( authenticated => 1 )->to( 'User#update', namespace => $namespace );

    # get all deliveryservices assigned to a user (from deliveryservice_tmuser table)
    $r->get( "/api/$version/users/:id/deliveryservices")->over( authenticated => 1 )->to( 'Deliveryservice#get_deliveryservices_by_userId', namespace => $namespace );

    # -- USERS: CURRENT USER
	$r->get("/api/$version/user/current")->over( authenticated => 1 )->to( 'User#current', namespace => $namespace );
	$r->post("/api/$version/user/current/update")->over( authenticated => 1 )->to( 'User#update_current', namespace => $namespace );

	# -- USERS: LOGIN
	# login w/ username and password
	$r->post("/api/$version/user/login")->to( 'User#login', namespace => $namespace );

	# login w/ token
	$r->post("/api/$version/user/login/token")->to( 'User#token_login', namespace => $namespace );

	# -- USERS: LOGOUT
	$r->post("/api/$version/user/logout")->over( authenticated => 1 )->to( 'Cdn#tool_logout', namespace => $namespace );

	# -- USERS: RESET PASSWORD
	$r->post("/api/$version/user/reset_password")->to( 'User#reset_password', namespace => $namespace );

	# -- USERS: ASSIGNED DELIVERYSERVICES
	$r->get("/api/$version/user/:id/deliveryservices/available")->over( authenticated => 1 )
		->to( 'User#get_available_deliveryservices', namespace => $namespace );

	# -- USERS: JOBS
	$r->get("/api/$version/user/current/jobs")->over( authenticated => 1 )->to( 'Job#index', namespace => $namespace );
	$r->post("/api/$version/user/current/jobs")->over( authenticated => 1 )->to( 'Job#create', namespace => $namespace );

	# -- RIAK
	# -- RIAK: KEYS
	#ping riak server
	$r->get("/api/$version/keys/ping")->over( authenticated => 1 )->to( 'Keys#ping_riak', namespace => $namespace );
	$r->get("/api/$version/riak/ping")->over( authenticated => 1 )->to( 'Riak#ping',      namespace => $namespace );
	$r->get("/api/$version/riak/bucket/#bucket/key/#key/values")->over( authenticated => 1 )->to( 'Riak#get', namespace => $namespace );

	# -- RIAK: STATS
	$r->get("/api/$version/riak/stats")->over( authenticated => 1 )->to( 'Riak#stats', namespace => $namespace );

	# -- EXTENSIONS
	$r->get("/api/$version/to_extensions")->over( authenticated => 1 )->to( 'ToExtension#index', namespace => $namespace );
	$r->post("/api/$version/to_extensions")->over( authenticated => 1 )->to( 'ToExtension#update', namespace => $namespace );
	$r->post("/api/$version/to_extensions/:id/delete")->over( authenticated => 1 )->to( 'ToExtension#delete', namespace => $namespace );

	# -- MISC
	# TM Status in use JvD
	$r->get("/api/$version/traffic_monitor/stats")->over( authenticated => 1 )->to( 'TrafficMonitor#get_host_stats', namespace => $namespace );

	# -- Ping API
	$r->get(
		"/api/$version/ping" => sub {
			my $self = shift;
			$self->render(
				json => {
					ping => "pong"
				}
			);
		}
	);
}

sub api_1_0_routes {
	my $self      = shift;
	my $r         = shift;
	my $namespace = shift;

	# ------------------------------------------------------------------------
	# API Routes
	# ------------------------------------------------------------------------
	# -- Parameter 1.0 API
	# deprecated - see: /api/$version/crans
	$r->get('/datacrans')->over( authenticated => 1 )->to( 'Asn#index', namespace => $namespace );
	$r->get('/datacrans/orderby/:orderby')->over( authenticated => 1 )->to( 'Asn#index', namespace => $namespace );

	# deprecated - see: /api/$version/locations
	$r->get('/datalocation')->over( authenticated => 1 )->to( 'Cachegroup#read', namespace => $namespace );

	# deprecated - see: /api/$version/locations
	$r->get('/datalocation/orderby/:orderby')->over( authenticated => 1 )->to( 'Cachegroup#read', namespace => $namespace );
	$r->get('/datalocationtrimmed')->over( authenticated => 1 )->to( 'Cachegroup#readlocationtrimmed', namespace => $namespace );

	# deprecated - see: /api/$version/locationparameters
	$r->get('/datalocationparameter')->over( authenticated => 1 )->to( 'CachegroupParameter#index', namespace => $namespace );

	# deprecated - see: /api/$version/logs
	$r->get('/datalog')->over( authenticated => 1 )->to( 'ChangeLog#readlog', namespace => $namespace );
	$r->get('/datalog/:days')->over( authenticated => 1 )->to( 'ChangeLog#readlog', namespace => $namespace );

	# deprecated - see: /api/$version/parameters
	$r->get('/dataparameter')->over( authenticated => 1 )->to( 'Parameter#readparameter', namespace => $namespace );
	$r->get('/dataparameter/#profile_name')->over( authenticated => 1 )->to( 'Parameter#readparameter_for_profile', namespace => $namespace );
	$r->get('/dataparameter/orderby/:orderby')->over( authenticated => 1 )->to( 'Parameter#readparameter', namespace => $namespace );

	# deprecated - see: /api/$version/profiles
	$r->get('/dataprofile')->over( authenticated => 1 )->to( 'Profile#readprofile', namespace => $namespace );
	$r->get('/dataprofile/orderby/:orderby')->over( authenticated => 1 )->to( 'Profile#readprofile', namespace => $namespace );
	$r->get('/dataprofiletrimmed')->over( authenticated => 1 )->to( 'Profile#readprofiletrimmed', namespace => $namespace );

	# deprecated - see: /api/$version/hwinfo
	$r->get('/datahwinfo')->over( authenticated => 1 )->to( 'HwInfo#readhwinfo', namespace => $namespace );
	$r->get('/datahwinfo/orderby/:orderby')->over( authenticated => 1 )->to( 'HwInfo#readhwinfo', namespace => $namespace );

	# deprecated - see: /api/$version/profileparameters
	$r->get('/dataprofileparameter')->over( authenticated => 1 )->to( 'ProfileParameter#read', namespace => $namespace );
	$r->get('/dataprofileparameter/orderby/:orderby')->over( authenticated => 1 )->to( 'ProfileParameter#read', namespace => $namespace );

	# deprecated - see: /api/$version/deliveryserviceserver
	$r->get('/datalinks')->over( authenticated => 1 )->to( 'DataAll#data_links', namespace => $namespace );
	$r->get('/datalinks/orderby/:orderby')->over( authenticated => 1 )->to( 'DataAll#data_links', namespace => $namespace );

	# deprecated - see: /api/$version/deliveryserviceserver
	$r->get('/datadeliveryserviceserver')->over( authenticated => 1 )->to( 'DeliveryServiceServer#read', namespace => $namespace );

	# deprecated - see: /api/$version/cdn/domains
	$r->get('/datadomains')->over( authenticated => 1 )->to( 'DataAll#data_domains', namespace => $namespace );

	# deprecated - see: /api/$version/user/:id/deliveryservices/available
	$r->get('/availableds/:id')->over( authenticated => 1 )->to( 'DataAll#availableds', namespace => $namespace );

	# deprecated - see: /api/$version/deliveryservices
	#$r->get('/datadeliveryservice')->over( authenticated => 1 )->to('DeliveryService#read', namespace => $namespace );
	$r->get('/datadeliveryservice')->to( 'DeliveryService#read', namespace => $namespace );
	$r->get('/datadeliveryservice/orderby/:orderby')->over( authenticated => 1 )->to( 'DeliveryService#read', namespace => $namespace );

	# deprecated - see: /api/$version/deliveryservices
	$r->get('/datastatus')->over( authenticated => 1 )->to( 'Status#index', namespace => $namespace );
	$r->get('/datastatus/orderby/:orderby')->over( authenticated => 1 )->to( 'Status#index', namespace => $namespace );

	# deprecated - see: /api/$version/users
	$r->get('/datauser')->over( authenticated => 1 )->to( 'User#read', namespace => $namespace );
	$r->get('/datauser/orderby/:orderby')->over( authenticated => 1 )->to( 'User#read', namespace => $namespace );

	# deprecated - see: /api/$version/phys_locations
	$r->get('/dataphys_location')->over( authenticated => 1 )->to( 'PhysLocation#readphys_location', namespace => $namespace );
	$r->get('/dataphys_locationtrimmed')->over( authenticated => 1 )->to( 'PhysLocation#readphys_locationtrimmed', namespace => $namespace );

	# deprecated - see: /api/$version/regions
	$r->get('/dataregion')->over( authenticated => 1 )->to( 'PhysLocation#readregion', namespace => $namespace );

	# deprecated - see: /api/$version/roles
	$r->get('/datarole')->over( authenticated => 1 )->to( 'Role#read', namespace => $namespace );
	$r->get('/datarole/orderby/:orderby')->over( authenticated => 1 )->to( 'Role#read', namespace => $namespace );

	# deprecated - see: /api/$version/servers and /api/1.1/servers/hostname/:host_name/details
	# WARNING: unauthenticated
	#TODO JvD over auth after we have rascal pointed over!!
	$r->get('/dataserver')->to( 'Server#index_response', namespace => $namespace );
	$r->get('/dataserver/orderby/:orderby')->to( 'Server#index_response', namespace => $namespace );
	$r->get('/dataserverdetail/select/:select')->over( authenticated => 1 )->to( 'Server#serverdetail', namespace => $namespace )
		;    # legacy route - rm me later

	# deprecated - see: /api/$version//api/1.1/staticdnsentries
	$r->get('/datastaticdnsentry')->over( authenticated => 1 )->to( 'StaticDnsEntry#read', namespace => $namespace );

	# -- Type
	# deprecated - see: /api/$version/types
	$r->get('/datatype')->over( authenticated => 1 )->to( 'Types#readtype', namespace => $namespace );
	$r->get('/datatypetrimmed')->over( authenticated => 1 )->to( 'Types#readtypetrimmed', namespace => $namespace );
	$r->get('/datatype/orderby/:orderby')->over( authenticated => 1 )->to( 'Types#readtype', namespace => $namespace );
}

sub traffic_stats_routes {
	my $self      = shift;
	my $r         = shift;
	my $version   = shift;
	my $namespace = "Extensions::TrafficStats::API";

	$r->get("/api/$version/cdns/usage/overview")->to( 'CdnStats#get_usage_overview', namespace => $namespace );
	$r->get("/api/$version/deliveryservice_stats")->over( authenticated => 1 )->to( 'DeliveryServiceStats#index', namespace => $namespace );
	$r->get("/api/$version/cache_stats")->over( authenticated => 1 )->to( 'CacheStats#index', namespace => $namespace );
	$r->get("internal/api/$version/daily_summary")->to( 'CacheStats#daily_summary', namespace => $namespace );
	$r->get("internal/api/$version/current_stats")->to( 'CacheStats#current_stats', namespace => $namespace );
}

sub catch_all {
	my $self      = shift;
	my $r         = shift;
	my $namespace = shift;

	# -- CATCH ALL
	$r->get('/api/(*everything)')->to( 'Cdn#catch_all', namespace => $namespace );
	$r->post('/api/(*everything)')->to( 'Cdn#catch_all', namespace => $namespace );
	$r->put('/api/(*everything)')->to( 'Cdn#catch_all', namespace => $namespace );
	$r->delete('/api/(*everything)')->to( 'Cdn#catch_all', namespace => $namespace );

	$r->get(
		'/(*everything)' => sub {
			my $self = shift;

			if ( defined( $self->current_user() ) ) {
				$self->render( template => "not_found", status => 404 );
			}
			else {
				$self->flash( login_msg => "Unauthorized . Please log in ." );
				$self->render( controller => 'cdn', action => 'loginpage', layout => undef, status => 401 );
			}
		}
	);
}

1;

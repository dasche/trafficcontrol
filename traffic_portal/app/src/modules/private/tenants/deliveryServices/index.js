/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

module.exports = angular.module('trafficPortal.private.tenants.deliveryServices', [])
	.config(function($stateProvider, $urlRouterProvider) {
		$stateProvider
			.state('trafficPortal.private.tenants.deliveryServices', {
				url: '/{tenantId}/delivery-services?all',
				views: {
					tenantsContent: {
						templateUrl: 'common/modules/table/tenantDeliveryServices/table.tenantDeliveryServices.tpl.html',
						controller: 'TableTenantDeliveryServicesController',
						resolve: {
							tenant: function($stateParams, tenantService) {
								return tenantService.getTenant($stateParams.tenantId);
							},
							deliveryServices: function($stateParams, tenant, deliveryServiceService) {
								if ($stateParams.all && $stateParams.all === 'true') {
									return deliveryServiceService.getDeliveryServices({ accessibleTo: tenant.id });
								}
								return deliveryServiceService.getDeliveryServices({ tenant: tenant.id });
							}
						}
					}
				}
			})
		;
		$urlRouterProvider.otherwise('/');
	});

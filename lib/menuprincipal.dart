import 'package:flutter/material.dart';

class MENUPRINCIPAL extends StatefulWidget {
	const MENUPRINCIPAL({super.key});
	@override
	MENUPRINCIPALState createState() => MENUPRINCIPALState();
}
class MENUPRINCIPALState extends State<MENUPRINCIPAL> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Container(
					constraints: const BoxConstraints.expand(),
					color: Color(0xFFFFFFFF),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: IntrinsicHeight(
									child: Container(
										color: Color(0xFFFFFFFF),
										width: double.infinity,
										height: double.infinity,
										child: SingleChildScrollView(
											padding: const EdgeInsets.only( bottom: 504),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Container(
														height: 149,
														width: double.infinity,
														child: Image.network(
															"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/55dx0k28_expires_30_days.png",
															fit: BoxFit.fill,
														)
													),
													IntrinsicHeight(
														child: Container(
															margin: const EdgeInsets.symmetric(horizontal: 24),
															width: double.infinity,
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.start,
																children: [
																	IntrinsicHeight(
																		child: Container(
																			padding: const EdgeInsets.only( top: 13, bottom: 13, right: 28),
																			margin: const EdgeInsets.only( bottom: 48),
																			width: double.infinity,
																			decoration: BoxDecoration(
																				image: DecorationImage(
																					image: NetworkImage("https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/tnh0ovci_expires_30_days.png"),
																					fit: BoxFit.fill
																				),
																			),
																			child: Column(
																				crossAxisAlignment: CrossAxisAlignment.end,
																				children: [
																					Text(
																						"SJC",
																						style: TextStyle(
																							color: Color(0xFFAEB4B5),
																							fontSize: 19,
																						),
																					),
																				]
																			),
																		),
																	),
																	Container(
																		margin: const EdgeInsets.only( left: 7),
																		width: 128,
																		height: 104,
																		child: Image.network(
																			"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/wzMjUWejTS/hwekbzxp_expires_30_days.png",
																			fit: BoxFit.fill,
																		)
																	),
																]
															),
														),
													),
												],
											)
										),
									),
								),
							),
						],
					),
				),
			),
		);
	}
}
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/componentes/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/status.dart';

class HomeLayout extends StatelessWidget {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleTextController = TextEditingController();
  var dateTextController = TextEditingController();
  var timeTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context)  => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStatus>(
        listener: (BuildContext context, state) {
          if(state is AppInsertDatabaseStatus){
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, state) {
          AppCubit cubit = AppCubit().get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                  cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: true,
              builder: (BuildContext context) => cubit.screens[cubit.currentIndex],
              fallback: (BuildContext context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if(cubit.isBottomSheetShown){
                  if(formKey.currentState.validate()){
                    cubit.insertToDatabase(title: titleTextController.text, date: dateTextController.text, time: timeTextController.text);
                  }
                }else {
                  scaffoldKey.currentState.showBottomSheet(
                          (context) => Container(
                            padding: EdgeInsets.all(20.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultTextField(
                                      controller: titleTextController,
                                      type: TextInputType.text,
                                      validator: (value){
                                        if(value.isEmpty){
                                          return 'Title must not be empty';
                                        }
                                        return null;
                                      },
                                      label: 'Task Title',
                                      prefixIcon: Icons.title,
                                  ),
                                  SizedBox(height: 15.0,),
                                  defaultTextField(
                                      controller: timeTextController,
                                      type: TextInputType.datetime,
                                      validator: (value){
                                        if(value.isEmpty){
                                          return 'Time must not be empty';
                                        }
                                        return null;
                                      },
                                    onTap: (){
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) =>  timeTextController.text = value.format(context).toString());
                                    },
                                      label: 'Task Time',
                                      prefixIcon:  Icons.watch_later_outlined,
                                  ),
                                  SizedBox(height: 15.0,),
                                  defaultTextField(
                                      controller: dateTextController,
                                      type: TextInputType.datetime,
                                      validator:  (value){
                                        if(value.isEmpty){
                                          return 'Date must not be empty';
                                        }
                                        return null;
                                      },
                                      onTap: (){
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.parse('2030-01-01'),
                                        ).then((value) => dateTextController.text = DateFormat.yMMMd().format(value));
                                      },
                                      label: 'Task Date',
                                      prefixIcon: Icons.date_range,
                                  ),
                                ],
                              ),
                            ),
                          ),
                    elevation: 20.0,
                  ).closed.then((value) {
                    cubit.changeBottomSheetState(isShow: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index){
                cubit.changeBottomNavBar(
                    index: index
                );
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks'
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done'
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'archived'
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

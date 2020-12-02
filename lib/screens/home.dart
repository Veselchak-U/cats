import 'package:get_pet/import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class HomeScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/home',
      builder: (_) => this,
      fullscreenDialog: false,
      isInitialRoute: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
      return BlocBuilder<HomeCubit, HomeState>(
        // buildWhen: (HomeState previous, HomeState current) =>
        //     current.status != previous.status,
        builder: (BuildContext context, HomeState state) {
          HomeCubit homeCubit = BlocProvider.of<HomeCubit>(context);
          ProfileCubit profileCubit = BlocProvider.of<ProfileCubit>(context);
          Widget result;
          if (state.status == HomeStatus.ready ||
              state.status == HomeStatus.reload) {
            result = RefreshIndicator(
              onRefresh: () => homeCubit.load(isReload: true),
              child: Scaffold(
                key: _scaffoldKey,
                appBar: _AppBar(),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Greeting(),
                      _StaticSearchBar(),
                      profileCubit.state.visibleSections[0]
                          ? _Header(index: 0, text: 'Pet Category')
                          : SizedBox.shrink(),
                      profileCubit.state.visibleSections[0]
                          ? _CategoryGrid()
                          : SizedBox.shrink(),
                      profileCubit.state.visibleSections[1]
                          ? _Header(index: 1, text: 'Newest Pet')
                          : SizedBox.shrink(),
                      profileCubit.state.visibleSections[1]
                          ? _NewestPetsCarousel()
                          : SizedBox.shrink(),
                      profileCubit.state.visibleSections[2]
                          ? _Header(index: 2, text: 'Vets Near You')
                          : SizedBox.shrink(),
                      profileCubit.state.visibleSections[2]
                          ? _VetsCarousel()
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                drawer: Drawer(
                  child: _Drawer(),
                ),
              ),
            );
          } else if (state.status == HomeStatus.busy) {
            result = Container(
              color: theme.backgroundColor,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state.status == HomeStatus.initial) {
            result = Container(
              color: theme.backgroundColor,
              child: Center(
                child: Text('HomeStatus.initial'),
              ),
            );
          } else {
            result = Container(
              color: theme.backgroundColor,
              child: Center(
                child: Text('Unknown HomeStatus'),
              ),
            );
          }
          return result;
        },
      );
    });
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    HomeCubit cubit = BlocProvider.of<HomeCubit>(context);
    HomeState data = cubit.state;
    var theme = Theme.of(context);
    return AppBar(
      elevation: 0.0,
      leading: IconButton(
        tooltip: 'Menu',
        icon: Icon(Icons.menu),
        onPressed: () {
          _scaffoldKey.currentState.openDrawer();
        },
      ),
      actions: [
        (data.notificationCount != null && data.notificationCount > 0)
            ? Stack(
                alignment: Alignment(1.0, -0.5),
                children: [
                  Center(
                    child: IconButton(
                      tooltip:
                          'You have ${data.notificationCount} new notification(s)',
                      icon: Icon(Icons.notifications_none),
                      onPressed: () {
                        cubit.clearNotifications();
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        // constraints: BoxConstraints(minWidth: 17, minHeight: 17),
                        decoration: BoxDecoration(
                          color: theme.selectedRowColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          child: Text(
                            '${data.notificationCount > 99 ? "99+" : data.notificationCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox.shrink(),
        SizedBox(width: kHorizontalPadding),
      ],
    );
  }
}

class _Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    return
        // Container(
        //   child: Column(
        //     children: [
        //       // Container(
        //       //   height: 150,
        //       //   child: Placeholder(),
        //       // ),
        //       DrawerHeader(
        //         child: Text('DrawerHeader'),
        //       ),
        LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // print('constraints.maxHeight = ${constraints.maxHeight}');
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _DrawerBody(),
                _DrawerButton(),
              ],
            ),
          ),
        );
      },
    );
    //     ],
    //   ),
    // );
  }
}

class _DrawerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProfileCubit profileCubit = BlocProvider.of<ProfileCubit>(context);
    List<Widget> menuItems = [];
    menuItems.add(
      _UserProfileCard(),
    );
    menuItems.add(
      ListTile(
        leading: Icon(Icons.restore_page),
        title: Text('Restore sections visibility'),
        onTap: profileCubit.restoreSectionsVisibility,
      ),
    );
    menuItems.addAll(
      List.generate(
        5,
        (index) => ExpansionTile(
          title: ListTile(
            leading: Icon(Icons.ac_unit),
            title: Text('MenuItem $index'),
          ),
          children: List.generate(
            3,
            (index2) => Padding(
              padding: const EdgeInsets.only(left: 24),
              child: ListTile(
                leading: Icon(Icons.menu_open),
                title: Text('MenuItem $index.$index2'),
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    return Column(
      children: menuItems,
    );
  }
}

class _DrawerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: () {
          navigator.pop();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding),
          child: Text('Log out'),
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Theme.of(context).primaryColorLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _UserProfileAvatar(),
            SizedBox(width: 16),
            Text(
              'John Doe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      //Placeholder(),
    );
  }
}

class _UserProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeCubit cubit = BlocProvider.of<HomeCubit>(context);
    HomeState data = cubit.state;
    // var theme = Theme.of(context);
    return FloatingActionButton(
      tooltip: 'Your profile',
      heroTag: 'HomeScreen_UserProfile',
      backgroundColor: theme.backgroundColor,
      // mini: true,
      onPressed: () {
        cubit.addNotification();
      },
      child: CircleAvatar(
        radius: 26.0,
        backgroundColor: theme.backgroundColor,
        backgroundImage:
            (data.userAvatarImage != null && data.userAvatarImage.isNotEmpty)
                ? NetworkImage(data.userAvatarImage)
                : AssetImage('${kAssetPath}placeholder_avatar.png'),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kHorizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              Text(
                'Find Your',
                style: TextStyle(
                    color: theme.primaryColorDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Lovely pet in anywhere',
                style: TextStyle(
                  color: theme.primaryColorDark,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              navigator.push(AddPetScreen().getRoute());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  /* horizontal: kHorizontalPadding */),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pets),
                  SizedBox(width: 8),
                  Text('Or Add'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: kHorizontalPadding, top: 16.0),
      child: GestureDetector(
        onTap: () {
          navigator.push(SearchScreen().getRoute());
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.0),
              bottomLeft: Radius.circular(32.0),
            ),
            color: theme.primaryColorLight,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 0.0, 4.0),
            child: TextField(
              enabled: false,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  _Header({
    this.index,
    this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    ProfileCubit profileCubit = BlocProvider.of<ProfileCubit>(context);
    HomeCubit homeCubit = BlocProvider.of<HomeCubit>(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(kHorizontalPadding, 4.0, 8.0, 4.0),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
                color: theme.primaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
          Spacer(),
          PopupMenuButton(
            icon: Icon(Icons.more_horiz),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: index,
                child: Text('Hide section'),
              )
            ],
            onSelected: (value) {
              homeCubit.addNotification();
              profileCubit.hideSection(index);
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.more_horiz),
          //   onPressed: () {
          //     cubit.addNotification();
          //   },
          // ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeCubit cubit = BlocProvider.of<HomeCubit>(context);
    HomeState data = cubit.state;
    final screenWidth = MediaQuery.of(context).size.width;
    var itemHeight = 60;
    var itemWidth = (screenWidth - 3 * kHorizontalPadding) / 2;
    var innerPadding = itemWidth > 160 ? 16.0 : 8.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kHorizontalPadding),
      child: GridView.count(
        crossAxisCount: 2,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        childAspectRatio: itemWidth / itemHeight,
        mainAxisSpacing: kHorizontalPadding,
        crossAxisSpacing: kHorizontalPadding,
        children: data.petCategories
            .map((CategoryModel element) => _CategoryGridItem(
                  item: element,
                  innerPadding: innerPadding,
                ))
            .toList(),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({this.item, this.innerPadding});

  final CategoryModel item;
  final double innerPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: () {
        navigator.push(SearchScreen(
          category: item,
        ).getRoute());
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(
            color: theme.primaryColorLight,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: innerPadding,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundColor:
                    item.backgroundColor ?? theme.primaryColorLight,
                child: CircleAvatar(
                  radius: 13.0,
                  backgroundColor:
                      item.backgroundColor ?? theme.primaryColorLight,
                  child: item.assetImage != null
                      ? Image.asset(
                          '$kAssetPath${item.assetImage}',
                          fit: BoxFit.scaleDown,
                        )
                      : null,
                ),
              ),
              SizedBox(width: innerPadding),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total of ${item.totalOf}',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewestPetsCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeCubit cubit = BlocProvider.of<HomeCubit>(context);
    HomeState data = cubit.state;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kHorizontalPadding),
      child: Container(
        height: 255,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: data.newestPets.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(kHorizontalPadding / 2),
            child: _NewestCarouselItem(
              item: data.newestPets[index],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewestCarouselItem extends StatelessWidget {
  const _NewestCarouselItem({Key key, this.item}) : super(key: key);
  final PetModel item;
  @override
  Widget build(BuildContext context) {
    HomeCubit cubit = BlocProvider.of<HomeCubit>(context);
    HomeState data = cubit.state;
    var theme = Theme.of(context);
    // ConditionModel itemCondition = data.conditions
    //     .firstWhere((ConditionModel e) => e.id == item.condition);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - (kHorizontalPadding * 4)) / 2;
    return GestureDetector(
      onTap: () {
        navigator.push(DetailScreen(cubit: cubit, item: item).getRoute());
      },
      child: Container(
        width: cardWidth < 200 ? cardWidth : 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.primaryColorLight,
            width: 2.0,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: '${item.id}',
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14.0),
                        topRight: Radius.circular(14.0),
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(item.photos),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  right: -11,
                  child: FlatButton(
                    height: 30,
                    color: item.liked ? theme.selectedRowColor : Colors.white,
                    shape: CircleBorder(),
                    onPressed: () {
                      cubit.onTapPetLike(petId: item.id);
                    },
                    child: Icon(
                      Icons.favorite,
                      color:
                          item.liked ? Colors.white : theme.textSelectionColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: item.condition.backgroundColor ??
                          theme.primaryColorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      child: Text(
                        item.condition.name ?? item.condition,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: item.condition.textColor ?? theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.breed.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                      ),
                      Text(
                        '${item.address} ( ${item.distance} km )',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VetsCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeCubit cubit = BlocProvider.of<HomeCubit>(context);
    HomeState data = cubit.state;
    // var theme = Theme.of(context);
    return Container(
      height: 120,
      margin: EdgeInsets.only(bottom: kHorizontalPadding),
      child: PageView.builder(
        itemCount: data.nearestVets.length,
        // controller: PageController(viewportFraction: 1.0),
        itemBuilder: (context, index) =>
            _VetsCarouselItem(item: data.nearestVets[index]),
      ),
    );
  }
}

class _VetsCarouselItem extends StatelessWidget {
  const _VetsCarouselItem({Key key, this.item}) : super(key: key);
  final VetModel item;
  @override
  Widget build(BuildContext context) {
    HomeCubit cubit = BlocProvider.of<HomeCubit>(context);
    var borderWidth = 2.0;
    // var boxWidth = MediaQuery.of(context).size.width -
    //     _kHorizontalPadding * 2 -
    //     borderWidth * 4;
    return Container(
      // width: boxWidth,
      margin: EdgeInsets.symmetric(horizontal: kHorizontalPadding),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(
          color: theme.primaryColorLight,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          cubit.callToPhoneNumber(phone: item.phone);
        },
        // onLongPress: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 100,
                child: Image(
                  image: NetworkImage(item.logoImage),
                  fit: BoxFit.scaleDown,
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          // color: _baseColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 20,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          item.phone,
                          style: TextStyle(
                            // color: _baseColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: item.isOpenNow
                            ? Colors.green[100]
                            : Colors.blue[100],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: Text(
                          item.timetable,
                          style: TextStyle(
                            color: item.isOpenNow ? Colors.green : Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

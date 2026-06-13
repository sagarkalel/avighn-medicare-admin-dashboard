import 'package:avighn_medicare/blocs/auth/auth_cubit.dart';
import 'package:avighn_medicare/theme/app_theme.dart';
import 'package:avighn_medicare/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardShell extends StatefulWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});
  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 768) return _mobile();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _sidebar(w < 1200),
          Expanded(
            child: Column(
              children: [
                _topbar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobile() => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_pharmacy_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Avighn Medicare',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ),
    drawer: Drawer(
      backgroundColor: AppColors.sidebarBg,
      child: SafeArea(child: _sidebarContent(false)),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.go('/products/add'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Product'),
    ),
    body: widget.child,
  );

  Widget _sidebar(bool isTablet) {
    final col = _collapsed || isTablet;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: col ? 72 : 240,
      child: _sidebarContent(col),
    );
  }

  Widget _sidebarContent(bool col) {
    final path = GoRouterState.of(context).matchedLocation;
    return Container(
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          // Logo
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: col ? 0 : 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              mainAxisAlignment: col
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_pharmacy_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                if (!col) ...[
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      'Avighn Medicare',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Nav
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _navItem(
                    icon: Icons.medication_outlined,
                    activeIcon: Icons.medication_rounded,
                    label: 'Products',
                    route: '/products',
                    currentPath: path,
                    col: col,
                  ),
                ],
              ),
            ),
          ),
          // Bottom
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: col
                ? IconButton(
                    icon: Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.sidebarText,
                    ),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppConstants.adminDisplayName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Administrator',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.sidebarText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.logout_rounded,
                                size: 16,
                                color: AppColors.sidebarText,
                              ),
                              onPressed: _logout,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _collapsed = !_collapsed),
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          size: 16,
                          color: AppColors.sidebarText.withOpacity(0.5),
                        ),
                        label: Text(
                          'Collapse',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.sidebarText.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required String currentPath,
    required bool col,
  }) {
    final active = currentPath.startsWith(route);
    return Tooltip(
      message: col ? label : '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.symmetric(
              horizontal: col ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.sidebarActive.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: active
                  ? Border.all(color: AppColors.sidebarActive.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: col
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  active ? activeIcon : icon,
                  size: 20,
                  color: active ? AppColors.primary : AppColors.sidebarText,
                ),
                if (!col) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? Colors.white : AppColors.sidebarText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topbar() {
    final path = GoRouterState.of(context).matchedLocation;
    String title = 'Product Catalogue';
    if (path.endsWith('/add'))
      title = 'Add New Product';
    else if (path.endsWith('/edit'))
      title = 'Edit Product';
    else if (path.contains('/products/'))
      title = 'Product Details';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (path == '/products')
            ElevatedButton.icon(
              onPressed: () => context.go('/products/add'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _logout() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.read<AuthCubit>().logout();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}

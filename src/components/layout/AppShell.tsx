import { Outlet } from 'react-router-dom'
import { Sidebar, BottomTabBar, PageTransition } from './Navigation'
import { FloatingActionButton } from './FloatingActionButton'
import { useIsMobile, useIsTablet } from '../../hooks/useMediaQuery'
import { useAppStore } from '../../stores/useAppStore'

export function AppShell() {
  const isMobile = useIsMobile()
  const isTablet = useIsTablet()
  const collapsed = useAppStore((s) => s.sidebarCollapsed)

  const sidebarWidth = isMobile ? 0 : collapsed && isTablet ? 72 : isTablet ? 72 : 240

  return (
    <div className="min-h-full bg-[var(--bg)]">
      <Sidebar />
      <main
        className={`min-h-full transition-[padding] duration-300 ${isMobile ? 'pb-20 px-4 pt-4 safe-top' : 'px-6 py-6 safe-top'}`}
        style={{ paddingLeft: isMobile ? undefined : sidebarWidth + 24, paddingRight: 24 }}
      >
        <PageTransition>
          <Outlet />
        </PageTransition>
      </main>
      <BottomTabBar />
      <FloatingActionButton />
    </div>
  )
}

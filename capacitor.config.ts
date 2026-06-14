import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.hossein.clarity',
  appName: 'Clarity',
  webDir: 'dist',
  server: {
    iosScheme: 'capacitor',
  },
}

export default config

import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.dxbconnect.app',
  appName: 'DXB Connect',
  webDir: 'out',
  server: {
    // Dev local (RÈGLE ABSOLUE: Port 4000)
    url: 'http://localhost:4000',
    cleartext: true
    // Production: Railway backend
    // url: 'https://api-github-production-a848.up.railway.app',
  },
  ios: {
    contentInset: 'automatic',
    preferredContentMode: 'mobile',
    scheme: 'DXBConnect'
  }
}

export default config

import { Haptics, ImpactStyle } from '@capacitor/haptics'

export async function hapticLight() {
  try {
    await Haptics.impact({ style: ImpactStyle.Light })
  } catch {
    if ('vibrate' in navigator) navigator.vibrate(10)
  }
}

export async function hapticMedium() {
  try {
    await Haptics.impact({ style: ImpactStyle.Medium })
  } catch {
    if ('vibrate' in navigator) navigator.vibrate(20)
  }
}

export function vibrateTabLongPress() {
  if ('vibrate' in navigator) navigator.vibrate(10)
}

export const springs = {
  snappy: { type: 'spring', stiffness: 400, damping: 30 },
  smooth: { type: 'spring', stiffness: 300, damping: 28 },
  gentle: { type: 'spring', stiffness: 200, damping: 25 },
  bouncy: { type: 'spring', stiffness: 500, damping: 20 },
}

export const springTransitions = {
  modal: { ...springs.smooth, duration: 0.28 },
  pageEnter: { ...springs.smooth, duration: 0.35 },
  staggerItem: (i, base = 0.04) => ({
    ...springs.gentle,
    delay: i * base,
  }),
}

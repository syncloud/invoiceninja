import { test, expect } from '../fixtures'
import { shoot } from '../helpers/screenshot'
import {
  createInvoice,
  login,
  openClients,
  openInvoices,
  openProducts,
  row,
} from '../helpers/invoiceninja'
import { upgrade } from '../helpers/upgrade'

test('client, product and invoice survive the upgrade', async ({ page }) => {
  await test.step('login', async () => {
    await login(page)
    await expect(page.locator('[data-cy="companyDropdown"]')).toContainText(upgrade.company)
    await shoot(page, 'post-upgrade-main')
  })

  await test.step('client', async () => {
    await openClients(page)
    await expect(row(page, upgrade.client).first()).toBeVisible()
    await shoot(page, 'post-upgrade-client')
  })

  await test.step('product', async () => {
    await openProducts(page)
    await expect(row(page, upgrade.product).first()).toBeVisible()
    await shoot(page, 'post-upgrade-product')
  })

  await test.step('invoice', async () => {
    await openInvoices(page)
    await expect(row(page, upgrade.client).first()).toBeVisible()
    await shoot(page, 'post-upgrade-invoice')
  })

  await test.step('new invoice', async () => {
    await createInvoice(page, upgrade.client, upgrade.product)
    await shoot(page, 'post-upgrade-new-invoice')
  })
})

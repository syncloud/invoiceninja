import { test } from '../fixtures'
import { shoot } from '../helpers/screenshot'
import {
  createClient,
  createInvoice,
  createProduct,
  listed,
  login,
  nameCompany,
  openClients,
  openInvoices,
  openProducts,
} from '../helpers/invoiceninja'
import { upgrade } from '../helpers/upgrade'

test('released version holds a client, product and invoice', async ({ page }) => {
  await test.step('login', async () => {
    await login(page)
    await nameCompany(page, upgrade.company)
    await shoot(page, 'pre-upgrade-main')
  })

  await test.step('client', async () => {
    await openClients(page)
    if (!(await listed(page, upgrade.client))) {
      await createClient(page, upgrade.client)
    }
    await shoot(page, 'pre-upgrade-client')
  })

  await test.step('product', async () => {
    await openProducts(page)
    if (!(await listed(page, upgrade.product))) {
      await createProduct(page, upgrade.product, upgrade.price)
    }
    await shoot(page, 'pre-upgrade-product')
  })

  await test.step('invoice', async () => {
    await openInvoices(page)
    if (!(await listed(page, upgrade.client))) {
      await createInvoice(page, upgrade.client, upgrade.product)
    }
    await shoot(page, 'pre-upgrade-invoice')
  })
})

# Diffable Data Sources


Some links to read

* [Tableview Docs](https://developer.apple.com/documentation/uikit/uitableviewdiffabledatasource)
* [Collectionview Docs](https://developer.apple.com/documentation/uikit/uicollectionviewdiffabledatasource)
* WWDC 19 session [Advances in UIDataSources](https://developer.apple.com/videos/play/wwdc2019/220/)
* [combine + diffable data sources (thoughtbot)](https://thoughtbot.com/blog/combine-diffable-data-source)
* [A first look (sundell)](https://wwdcbysundell.com/2019/diffable-data-sources-first-look/)

Also

* revisit use in MusicJot
* Adapt to Borkle?

----------

But first, SPELUNK THE HEADERS.

* exists NS and UI Diffable data source headers
* looks like the same NSDiffableDataSourceSnapshot stuff, with extra frobs
  for UIKit/AppKit

### NSDiffableDataSourceSnapshot

* "a representation of the state of the data in a view at a specific
  point in time"
* generic over `SectionIdentifierType` and `ItemIdentifierType`
    - where both of those types are Hashable.
* diffable data sources use _snapshots_ to provide data for collection views
  and table views
   - set up the initial state of the data in the view
   - later update that data
* the data is made of the sections and items you want to display.
  - in the specific order to display them
  - configure by adding / deleting / mving sections and items
* **Important** each of the sections anditems must have unique identifiers.


To display

* create a snapshot and populate it with the state of the data to display
* apply the snapshot to reflect the changes in the UI

Ways to create and configure a snapshot

* Make an empty one, then append sections and items
* get the current snapshot by calling the diffableDataSource's `snapshot`
  then modify to reflect the new state.

All identifiers must be unique.  Section and item identifers do not 
overlap and may contain values that exist in the other (like to
have a section ID of 1 and and item ID of 1)

_so looks like all item identifers have to be unique across everything,
so can't have same item identifier in two sections_

If you have duplication values in an item or section, exception.


### PropZ

Looks like this is dealing with just identifiers, not actually the real
data.

* array of section identifiers
* array of item identifiers

* number of items
* number of sections

* number of items in section (via identifeir)
* item identifiers (array) in a section (via identifier)
* section identifier for section containing an item identifier
* index of item / section identifier (NSNotFound if not present)

item operators

* append items with identifiers (array of identifiers)
* append items with identifers into section with an identifier

* insert items with identifiers before item (identifier)
* insert items with identifiers after item (identifier)

* delete items with identifiers (array)
* delete ALL items.

* move item with identifier before another item (via identifier)
* move item with identifier after another item

* reload items with identifiers

section operations

(reduced notes since it matches the patterns above)

* append sections with identifiers

* insert sections before / after
* delete sections with identifiers
* move section before/after
* reload sections with identifiers

[ ] what do RELOAD do? (guess it can only be called on the existing snapshot,
    not a new one)


"diffable data source item provider"

```
NSCollectionViewItem * (^NSCollectionViewDiffableDataSourceItemProvider)
     (NSCollectionView * _Nonnull,
      NSIndexPath * _Nonnull, 
      ItemIdentifierType _Nonnull);
```

So takes a collection view, an index path, and an item provider.  Returns
a collection view item.  So this is the gasket between the item identifiers
and the actual pile of data.

----------

Guessing we don't get the really cool stuff - given two snapshots,
do something with them.  is that all hidden inside of table/collection
view.


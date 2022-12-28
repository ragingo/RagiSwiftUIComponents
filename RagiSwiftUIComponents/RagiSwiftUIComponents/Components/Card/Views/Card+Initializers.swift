//
//  Card+Initializers.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/25.
//

import SwiftUI

extension Card {
    public init<
        CardHeader: View,
        CardMedia: View,
        CardContent: View,
        CardActions: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader,
        @ViewBuilder media: @escaping () -> CardMedia,
        @ViewBuilder content: @escaping () -> CardContent,
        @ViewBuilder actions: @escaping () -> CardActions
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            CardMedia,
            CardContent,
            CardActions
        )>
    > {
        self.init(properties: properties) {
            VStack(spacing: 0) {
                header()
                media()
                content()
                actions()
            }
        }
    }
}

extension Card {
    public init<
        CardHeader: View,
        CardContent: View,
        CardActions: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader,
        @ViewBuilder content: @escaping () -> CardContent,
        @ViewBuilder actions: @escaping () -> CardActions
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            EmptyView,
            CardContent,
            CardActions
        )>
    > {
        self.init(header: header, media: { EmptyView() }, content: content, actions: actions)
    }
}

extension Card {
    public init<
        CardHeader: View,
        CardMedia: View,
        CardActions: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader,
        @ViewBuilder media: @escaping () -> CardMedia,
        @ViewBuilder actions: @escaping () -> CardActions
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            CardMedia,
            EmptyView,
            CardActions
        )>
    > {
        self.init(header: header, media: media, content: { EmptyView() }, actions: actions)
    }
}

extension Card {
    public init<
        CardHeader: View,
        CardMedia: View,
        CardContent: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader,
        @ViewBuilder media: @escaping () -> CardMedia,
        @ViewBuilder content: @escaping () -> CardContent
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            CardMedia,
            CardContent,
            EmptyView
        )>
    > {
        self.init(header: header, media: media, content: content, actions: { EmptyView() })
    }
}

extension Card {
    public init<
        CardHeader: View,
        CardMedia: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader,
        @ViewBuilder media: @escaping () -> CardMedia
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            CardMedia,
            EmptyView,
            EmptyView
        )>
    > {
        self.init(header: header, media: media, content: { EmptyView() }, actions: { EmptyView() })
    }
}

extension Card {
    public init<
        CardHeader: View,
        CardContent: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader,
        @ViewBuilder content: @escaping () -> CardContent
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            EmptyView,
            CardContent,
            EmptyView
        )>
    > {
        self.init(header: header, media: { EmptyView() }, content: content, actions: { EmptyView() })
    }
}

extension Card {
    public init<
        CardHeader: View,
        CardActions: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader,
        @ViewBuilder actions: @escaping () -> CardActions
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            EmptyView,
            EmptyView,
            CardActions
        )>
    > {
        self.init(header: header, media: { EmptyView() }, content: { EmptyView() }, actions: actions)
    }
}

extension Card {
    public init<
        CardHeader: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            EmptyView,
            EmptyView,
            EmptyView
        )>
    > {
        self.init(header: header, media: { EmptyView() }, content: { EmptyView() }, actions: { EmptyView() })
    }
}

extension Card {
    public init<
        CardMedia: View,
        CardActions: View
    >(
        properties: Properties? = nil,
        @ViewBuilder media: @escaping () -> CardMedia,
        @ViewBuilder actions: @escaping () -> CardActions
    ) where Content == VStack<
        TupleView<(
            EmptyView,
            CardMedia,
            EmptyView,
            CardActions
        )>
    > {
        self.init(header: { EmptyView() }, media: media, content: { EmptyView() }, actions: actions)
    }
}

extension Card {
    public init<
        CardMedia: View,
        CardContent: View
    >(
        properties: Properties? = nil,
        @ViewBuilder media: @escaping () -> CardMedia,
        @ViewBuilder content: @escaping () -> CardContent
    ) where Content == VStack<
        TupleView<(
            EmptyView,
            CardMedia,
            CardContent,
            EmptyView
        )>
    > {
        self.init(header: { EmptyView() }, media: media, content: content, actions: { EmptyView() })
    }
}

extension Card {
    public init<
        CardContent: View,
        CardActions: View
    >(
        properties: Properties? = nil,
        @ViewBuilder content: @escaping () -> CardContent,
        @ViewBuilder actions: @escaping () -> CardActions
    ) where Content == VStack<
        TupleView<(
            EmptyView,
            EmptyView,
            CardContent,
            CardActions
        )>
    > {
        self.init(header: { EmptyView() }, media: { EmptyView() }, content: content, actions: actions)
    }
}

extension Card {
    public init<
        CardActions: View
    >(
        properties: Properties? = nil,
        @ViewBuilder actions: @escaping () -> CardActions
    ) where Content == VStack<
        TupleView<(
            EmptyView,
            EmptyView,
            EmptyView,
            CardActions
        )>
    > {
        self.init(header: { EmptyView() }, media: { EmptyView() }, content: { EmptyView() }, actions: actions)
    }
}

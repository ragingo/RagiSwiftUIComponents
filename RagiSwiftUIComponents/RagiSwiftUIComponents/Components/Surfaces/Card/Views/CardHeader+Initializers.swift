//
//  CardHeader+Initializers.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/25.
//

import SwiftUI


extension CardHeader {
    // MARK: - Title + Subheader + Avator + Action
    public init<
        Title: View,
        Subheader: View,
        Avator: View,
        Action: View
    >(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder subheader: @escaping () -> Subheader,
        @ViewBuilder avator: @escaping () -> Avator,
        @ViewBuilder action: @escaping () -> Action
    ) where Content == HStack<
        TupleView<(
            Avator,
            VStack<TupleView<(Title, Subheader)>>,
            Spacer,
            Action
        )>
    > {
        self.init {
            HStack(alignment: .center, spacing: 16) {
                avator()
                VStack(alignment: .leading, spacing: 0) {
                    title()
                    subheader()
                }
                Spacer()
                action()
            }
        }
    }
}

extension CardHeader {
    // MARK: - Title + Subheader + Action
    public init<
        Title: View,
        Subheader: View,
        Action: View
    >(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder subheader: @escaping () -> Subheader,
        @ViewBuilder action: @escaping () -> Action
    ) where Content == HStack<
        TupleView<(
            EmptyView,
            VStack<TupleView<(Title, Subheader)>>,
            Spacer,
            Action
        )>
    > {
        self.init(title: title, subheader: subheader, avator: { EmptyView() }, action: action)
    }
}

extension CardHeader {
    // MARK: - Title + Subheader + Action
    public init<
        Title: View,
        Subheader: View,
        Avator: View
    >(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder subheader: @escaping () -> Subheader,
        @ViewBuilder avator: @escaping () -> Avator
    ) where Content == HStack<
        TupleView<(
            Avator,
            VStack<TupleView<(Title, Subheader)>>,
            Spacer,
            EmptyView
        )>
    > {
        self.init(title: title, subheader: subheader, avator: avator, action: { EmptyView() })
    }
}

extension CardHeader {
    // MARK: - Title + Subheader
    public init<
        Title: View,
        Subheader: View
    >(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder subheader: @escaping () -> Subheader
    ) where Content == HStack<
        TupleView<(
            EmptyView,
            VStack<TupleView<(Title, Subheader)>>,
            Spacer,
            EmptyView
        )>
    > {
        self.init(title: title, subheader: subheader, avator: { EmptyView() }, action: { EmptyView() })
    }
}

extension CardHeader {
    // MARK: - Title + Avator + Action
    public init<
        Title: View,
        Avator: View,
        Action: View
    >(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder avator: @escaping () -> Avator,
        @ViewBuilder action: @escaping () -> Action
    ) where Content == HStack<
        TupleView<(
            Avator,
            VStack<TupleView<(Title, EmptyView)>>,
            Spacer,
            Action
        )>
    > {
        self.init(title: title, subheader: { EmptyView() }, avator: avator, action: action)
    }
}

extension CardHeader {
    // MARK: - Title + Action
    public init<
        Title: View,
        Action: View
    >(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder action: @escaping () -> Action
    ) where Content == HStack<
        TupleView<(
            EmptyView,
            VStack<TupleView<(Title, EmptyView)>>,
            Spacer,
            Action
        )>
    > {
        self.init(title: title, subheader: { EmptyView() }, avator: { EmptyView() }, action: action)
    }
}

extension CardHeader {
    // MARK: - Title + Avator
    public init<
        Title: View,
        Avator: View
    >(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder avator: @escaping () -> Avator
    ) where Content == HStack<
        TupleView<(
            Avator,
            VStack<TupleView<(Title, EmptyView)>>,
            Spacer,
            EmptyView
        )>
    > {
        self.init(title: title, subheader: { EmptyView() }, avator: avator, action: { EmptyView() })
    }
}

extension CardHeader {
    // MARK: - Title
    public init<
        Title: View
    >(
        @ViewBuilder title: @escaping () -> Title
    ) where Content == HStack<
        TupleView<(
            EmptyView,
            VStack<TupleView<(Title, EmptyView)>>,
            Spacer,
            EmptyView
        )>
    > {
        self.init(title: title, subheader: { EmptyView() }, avator: { EmptyView() }, action: { EmptyView() })
    }
}
